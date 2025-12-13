use std::fs;
use std::path::PathBuf;
use serde::Serialize;
use svg_hir::svg_element_enum::SvgElementEnum;
use usvg::{Node, Tree, Group, parser::EId, Paint};
use svg_hir::text::{Text as HirText};
use svg_hir::style::Style;
use svg_hir::color::Color;
use edit_distance::edit_distance;
use svg_hir::traits::svg_component::SvgComponent;

#[derive(Serialize, Debug)]
struct SimilarityReport {
    element_a: String,
    element_b: String,
    similarity_score: f32,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = pico_args::Arguments::from_env();

    let input_svg_path: PathBuf = args.value_from_os_str("--input", |s| -> Result<PathBuf, String> { Ok(PathBuf::from(s)) })?;
    let output_json_path: PathBuf = args.value_from_os_str("--output", |s| -> Result<PathBuf, String> { Ok(PathBuf::from(s)) })?;
    let similarity_threshold: f32 = args.opt_value_from_str("--threshold")?.unwrap_or(0.8);

    let svg_data = fs::read(&input_svg_path)?;
    let tree = Tree::from_data(&svg_data, &usvg::Options::default())?;

    let mut elements: Vec<SvgElementEnum> = Vec::new();
    collect_svg_elements(tree.root(), &mut elements);

    let mut reports: Vec<SimilarityReport> = Vec::new();

    for i in 0..elements.len() {
        for j in i + 1..elements.len() {
            let el_a = &elements[i];
            let el_b = &elements[j];

            let score = calculate_similarity(el_a, el_b);

            if score >= similarity_threshold {
                if let (Some(id_a), Some(id_b)) = (el_a.id(), el_b.id()) {
                    reports.push(SimilarityReport {
                        element_a: id_a.to_string(),
                        element_b: id_b.to_string(),
                        similarity_score: score,
                    });
                }
            }
        }
    }

    let json_content = serde_json::to_string_pretty(&reports)?;
    
    if let Some(parent) = output_json_path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&output_json_path, json_content)?;

    println!("Similarity report written to {}", output_json_path.display());
    Ok(())
}

fn calculate_similarity(a: &SvgElementEnum, b: &SvgElementEnum) -> f32 {
    let shape_score = match (a, b) {
        (SvgElementEnum::Path(p1), SvgElementEnum::Path(p2)) => {
            let dist = edit_distance(&p1.d, &p2.d) as f32;
            1.0 - (dist / (p1.d.len().max(p2.d.len()) as f32))
        }
        (SvgElementEnum::Circle(c1), SvgElementEnum::Circle(c2)) => {
            1.0 - (c1.r - c2.r).abs() / (c1.r.max(c2.r))
        }
        (SvgElementEnum::Rect(r1), SvgElementEnum::Rect(r2)) => {
            let size_diff = (r1.width - r2.width).abs() + (r1.height - r2.height).abs();
            let max_size = r1.width.max(r2.width) + r1.height.max(r2.height);
            1.0 - size_diff / max_size
        }
        _ => 0.0,
    };

    let style1 = a.style();
    let style2 = b.style();

    let style_score = match (style1, style2) {
        (Some(s1), Some(s2)) => {
            let mut score = 0.0;
            let mut total = 0.0;

            if s1.fill.is_some() || s2.fill.is_some() {
                total += 1.0;
                if s1.fill == s2.fill {
                    score += 1.0;
                }
            }

            if s1.stroke.is_some() || s2.stroke.is_some() {
                total += 1.0;
                if s1.stroke == s2.stroke {
                    score += 1.0;
                }
            }

            if let (Some(w1), Some(w2)) = (s1.stroke_width, s2.stroke_width) {
                total += 1.0;
                score += 1.0 - (w1 - w2).abs() / w1.max(w2);
            }
            
            if total > 0.0 { score / total } else { 1.0 }
        }
        (None, None) => 1.0,
        _ => 0.0,
    };

    (shape_score * 0.5) + (style_score * 0.5)
}


fn collect_svg_elements(group: &Group, elements: &mut Vec<SvgElementEnum>) {
    for child in group.children() {
        if let Some(element) = convert_usvg_node_to_svg_element_enum(child) {
            elements.push(element);
        }
        
        if let Node::Group(g) = child {
            collect_svg_elements(g, elements);
        }
    }
}

fn convert_usvg_node_to_svg_element_enum(node: &Node) -> Option<SvgElementEnum> {
    match node {
        Node::Path(p) => {
            let bbox = p.bounding_box();
            let mut style = Style { fill: None, stroke: None, stroke_width: None };
            if let Some(f) = p.fill() {
                if let Paint::Color(c) = f.paint() {
                    style.fill = Some(Color { r: c.red, g: c.green, b: c.blue, a: 255 });
                }
            }
            if let Some(s) = p.stroke() {
                if let Paint::Color(c) = s.paint() {
                    style.stroke = Some(Color { r: c.red, g: c.green, b: c.blue, a: 255 });
                }
                style.stroke_width = Some(s.width().get());
            }

            match p.original_eid {
                Some(EId::Rect) => Some(SvgElementEnum::Rect(svg_hir::rect::Rect {
                    id: Some(p.id().to_string()),
                    x: bbox.x(),
                    y: bbox.y(),
                    width: bbox.width(),
                    height: bbox.height(),
                    original_eid: p.original_eid,
                    style: Some(style),
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
                        style: Some(style),
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
                    style: Some(style),
                    ..Default::default()
                })),
                _ => { // Includes Path, Line, Polyline, Polygon
                    let path_data = path_to_string(p.data());
                    Some(SvgElementEnum::Path(svg_hir::path::Path {
                        id: Some(p.id().to_string()),
                        d: path_data,
                        original_eid: p.original_eid,
                        style: Some(style),
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