use std::fs;
use std::path::PathBuf;
use serde::Serialize;
use svg_hir::bsp_tree::BspTree;
use svg_hir::svg_element_enum::SvgElementEnum;
use svg_hir::bounding_box::BoundingBox;
use svg_hir::traits::svg_component::SvgComponent;
use usvg::{Node, Tree, Group};
use std::collections::HashMap;
use regex::Regex;
use svg_hir::text::{Text as HirText};
use svg_hir::Triple;

#[derive(Serialize)]
struct BuddyReport {
    element: String,
    creation_order_buddy: Option<String>,
    spatial_proximity_buddy: Option<String>,
    containment_buddies: Vec<String>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = pico_args::Arguments::from_env();

    let input_svg_path: PathBuf = args.value_from_os_str("--input", |s| -> Result<PathBuf, String> { Ok(PathBuf::from(s)) })?;
    let output_json_path: PathBuf = args.value_from_os_str("--output", |s| -> Result<PathBuf, String> { Ok(PathBuf::from(s)) })?;

    let alpha: f32 = args.opt_value_from_str("--alpha")?.unwrap_or(0.1);
    let max_depth: usize = args.opt_value_from_str("--max-depth")?.unwrap_or(8);

    let svg_data = fs::read(&input_svg_path)?;
    let tree = Tree::from_data(&svg_data, &usvg::Options::default())?;

    let mut elements: Vec<SvgElementEnum> = Vec::new();
    let mut containment_parent_map: HashMap<String, String> = HashMap::new(); // child_id -> parent_id
    
    collect_svg_elements(tree.root(), &mut elements, &mut containment_parent_map, "");

    // --- Creation Order Buddies ---
    let mut sorted_elements = elements.clone();
    sorted_elements.sort_by_key(|el| get_numeric_id(el.id().unwrap_or("")).unwrap_or(u32::MAX));
    let mut creation_order_buddies: HashMap<String, String> = HashMap::new();
    for i in 1..sorted_elements.len() {
        if let (Some(prev_id), Some(curr_id)) = (sorted_elements[i-1].id(), sorted_elements[i].id()) {
            creation_order_buddies.insert(curr_id.to_string(), prev_id.to_string());
        }
    }

    // --- Spatial Proximity Buddies ---
    let document_bbox = elements.iter().fold(BoundingBox::default(), |acc, el| {
        acc.union(&el.bounding_box())
    });
    let mut bsp_tree = BspTree::new(document_bbox, max_depth);
    bsp_tree.build(elements.clone());
    let mut spatial_buddies: HashMap<String, String> = HashMap::new();
    for element in &elements {
        if let Some(element_id) = element.id() {
            if let Some((buddy, _)) = bsp_tree.find_nearest_neighbor(element, alpha) {
                 if let Some(buddy_id) = buddy.id() {
                    spatial_buddies.insert(element_id.to_string(), buddy_id.to_string());
                }
            }
        }
    }

    // --- Generate Report ---
    let mut reports = Vec::new();
    for element in &elements {
        if let Some(element_id) = element.id() {
            let mut containment_buddies_list = Vec::new();
            if let Some(parent_id) = containment_parent_map.get(element_id) {
                for (child_id, p_id) in &containment_parent_map {
                    if p_id == parent_id && child_id != element_id {
                        containment_buddies_list.push(child_id.clone());
                    }
                }
            }

            reports.push(BuddyReport {
                element: element_id.to_string(),
                creation_order_buddy: creation_order_buddies.get(element_id).cloned(),
                spatial_proximity_buddy: spatial_buddies.get(element_id).cloned(),
                containment_buddies: containment_buddies_list,
            });
        }
    }

    let json_content = serde_json::to_string_pretty(&reports)?;
    
    if let Some(parent) = output_json_path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&output_json_path, json_content)?;

    println!("Buddy report written to {}", output_json_path.display());

    Ok(())
}

fn collect_svg_elements(group: &Group, elements: &mut Vec<SvgElementEnum>, containment_parent_map: &mut HashMap<String, String>, parent_id: &str) {
    for child in group.children() {
        if let Some(element) = convert_usvg_node_to_svg_element_enum(child) {
            let bbox = element.bounding_box();
            if !bbox.width.is_nan() && !bbox.height.is_nan() && bbox.width > 0.0 && bbox.height > 0.0 {
                if let Some(child_id) = element.id() {
                    if !parent_id.is_empty() {
                         containment_parent_map.insert(child_id.to_string(), parent_id.to_string());
                    }
                }
                elements.push(element);
            }
        }
        
        if let Node::Group(g) = child {
            collect_svg_elements(g, elements, containment_parent_map, child.id());
        }
    }
}

fn convert_usvg_node_to_svg_element_enum(node: &Node) -> Option<SvgElementEnum> {
    match node {
        Node::Path(p) => {
            let path_data = path_to_string(p.data());
            if p.bounding_box().width() > 0.0 && p.bounding_box().height() > 0.0 {
                Some(SvgElementEnum::Path(svg_hir::path::Path {
                    id: Some(p.id().to_string()),
                    d: path_data,
                    ..Default::default()
                }))
            } else {
                None
            }
        }
        Node::Group(g) if g.id().starts_with("rect") => {
            let bbox = g.bounding_box();
            Some(SvgElementEnum::Rect(svg_hir::rect::Rect {
                id: Some(g.id().to_string()),
                x: bbox.x(),
                y: bbox.y(),
                width: bbox.width(),
                height: bbox.height(),
                ..Default::default()
            }))
        }
        Node::Group(g) if g.id().starts_with("ellipse") || g.id().starts_with("path") && g.children().len() == 1 => {
            if let Some(Node::Path(p)) = g.children().get(0) {
                 let bbox = p.bounding_box();
                 let cx = bbox.x() + bbox.width() / 2.0;
                 let cy = bbox.y() + bbox.height() / 2.0;
                 let rx = bbox.width() / 2.0;
                 let ry = bbox.height() / 2.0;
                Some(SvgElementEnum::Ellipse(svg_hir::ellipse::Ellipse {
                    id: Some(g.id().to_string()),
                    cx,
                    cy,
                    rx,
                    ry,
                    ..Default::default()
                }))
            } else {
                 None
            }
        }
        Node::Text(t) => {
            let bbox = t.bounding_box();
            let mut content = String::new();
            for chunk in t.chunks() {
                content.push_str(chunk.text());
            }

            Some(SvgElementEnum::Text(HirText {
                id: Some(t.id().to_string()),
                x: bbox.x(),
                y: bbox.y(),
                content,
                word_count: 0, // TODO
                style: None,
                transform: None,
                triples: Vec::new(),
            }))
        }
        _ => None,
    }
}

fn path_to_string(path: &usvg::tiny_skia_path::Path) -> String {
    let mut s = String::new();
    for segment in path.segments() {
        match segment {
            usvg::tiny_skia_path::PathSegment::MoveTo(p) => {
                s.push_str(&format!("M {} {} ", p.x, p.y));
            }
            usvg::tiny_skia_path::PathSegment::LineTo(p) => {
                s.push_str(&format!("L {} {} ", p.x, p.y));
            }
            usvg::tiny_skia_path::PathSegment::QuadTo(p1, p) => {
                s.push_str(&format!("Q {} {} {} {} ", p1.x, p1.y, p.x, p.y));
            }
            usvg::tiny_skia_path::PathSegment::CubicTo(p1, p2, p) => {
                s.push_str(&format!("C {} {} {} {} {} {} ", p1.x, p1.y, p2.x, p2.y, p.x, p.y));
            }
            usvg::tiny_skia_path::PathSegment::Close => {
                s.push_str("Z ");
            }
        }
    }

    if s.ends_with(' ') {
        s.pop();
    }

    s
}


fn get_numeric_id(id: &str) -> Option<u32> {
    let re = Regex::new(r"\d+").unwrap();
    if let Some(mat) = re.find(id) {
        mat.as_str().parse().ok()
    } else {
        None
    }
}