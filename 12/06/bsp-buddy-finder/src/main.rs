use std::fs;
use std::path::PathBuf;
use serde::Serialize;
use svg_hir::bsp_tree::BspTree;
use svg_hir::svg_element_enum::SvgElementEnum;
use svg_hir::bounding_box::BoundingBox;
use svg_hir::traits::svg_component::SvgComponent;
use usvg::{Node, Tree, Group};
use usvg::parser::EId;
use std::collections::HashMap;
use svg_hir::text::{Text as HirText};

#[derive(Serialize)]
struct BuddyReport {
    element: String,
    creation_order_buddy: Option<String>,
    spatial_proximity_buddy: Option<String>,
    containment_buddies: Vec<String>,
    deep_containment_buddies: Vec<String>,
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
    sorted_elements.sort_by_key(|el| {
        el.id()
            .and_then(|id_str| id_str.split(|c: char| !c.is_digit(10)).last())
            .and_then(|num_str| num_str.parse::<u32>().ok())
            .unwrap_or(u32::MAX)
    });
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

    // --- Deep Containment Buddies ---
    let mut deep_containment_buddies: HashMap<String, Vec<String>> = HashMap::new();
    for i in 0..elements.len() {
        for j in 0..elements.len() {
            if i == j { continue; }

            let el_i = &elements[i];
            let el_j = &elements[j];

            if let (Some(id_i), Some(id_j)) = (el_i.id(), el_j.id()) {
                if el_i.bounding_box().contains(&el_j.bounding_box()) {
                    deep_containment_buddies.entry(id_i.to_string()).or_default().push(id_j.to_string());
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
                deep_containment_buddies: deep_containment_buddies.get(element_id).cloned().unwrap_or_default(),
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
            let bbox = p.bounding_box();
            match p.as_ref().original_eid {
                Some(EId::Rect) => Some(SvgElementEnum::Rect(svg_hir::rect::Rect {
                    id: Some(p.id().to_string()),
                    x: bbox.x(),
                    y: bbox.y(),
                    width: bbox.width(),
                    height: bbox.height(),
                    original_eid: p.original_eid,
                    ..Default::default()
                })),
                Some(EId::Circle) => {
                    let r = (bbox.width() + bbox.height()) / 4.0;
                    Some(SvgElementEnum::Circle(svg_hir::circle::Circle {
                        id: Some(p.id().to_string()),
                        cx: bbox.x() + r,
                        cy: bbox.y() + r,
                        r,
                        original_eid: p.original_eid,
                        ..Default::default()
                    }))
                }
                Some(EId::Ellipse) => Some(SvgElementEnum::Ellipse(svg_hir::ellipse::Ellipse {
                    id: Some(p.id().to_string()),
                    cx: bbox.x() + bbox.width() / 2.0,
                    cy: bbox.y() + bbox.height() / 2.0,
                    rx: bbox.width() / 2.0,
                    ry: bbox.height() / 2.0,
                    original_eid: p.original_eid,
                    ..Default::default()
                })),
                _ => { // Includes Path, Line, Polyline, Polygon
                    let path_data = path_to_string(p.data());
                    Some(SvgElementEnum::Path(svg_hir::path::Path {
                        id: Some(p.id().to_string()),
                        d: path_data,
                        original_eid: p.original_eid,
                        ..Default::default()
                    }))
                }
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
                original_eid: None,
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
    id.chars().filter(|c| c.is_digit(10)).collect::<String>().parse().ok()
}
