use std::io::BufReader;
use std::fs::File;
use xml::reader::{EventReader, XmlEvent};
use crate::{
    Svg, SvgElementEnum, Rect, Circle, Group, Text, Path, Ellipse,
    BoundingBox, Color, Transform, Style,
};

// --- Helper Functions for Parsing Attributes ---
fn get_attr_value<'a>(attributes: &'a [xml::attribute::OwnedAttribute], name: &str) -> Option<String> {
    attributes.iter().find(|attr| attr.name.local_name == name).map(|attr| attr.value.clone())
}

fn get_attr_f32(attributes: &[xml::attribute::OwnedAttribute], name: &str) -> f32 {
    get_attr_value(attributes, name).and_then(|s| s.parse::<f32>().ok()).unwrap_or_default()
}

fn calculate_path_bbox_approx(_d_attr: &str) -> BoundingBox {
    // This is a placeholder. A real implementation would be more complex.
    BoundingBox::new(0.0, 0.0, 0.0, 0.0)
}

fn parse_style(style_str: Option<String>) -> Option<Style> {
    // This is a simplified parser. A real implementation would be more robust.
    style_str.map(|s| {
        let mut style = Style { fill: None, stroke: None, stroke_width: None };
        for part in s.split(';') {
            let mut parts = part.split(':');
            if let (Some(key), Some(value)) = (parts.next(), parts.next()) {
                match key.trim() {
                    "fill" => style.fill = parse_color(value.trim()),
                    "stroke" => style.stroke = parse_color(value.trim()),
                    "stroke-width" => style.stroke_width = value.trim().parse().ok(),
                    _ => {},
                }
            }
        }
        style
    })
}

fn parse_color(color_str: &str) -> Option<Color> {
    if color_str.starts_with('#') {
        let hex = &color_str[1..];
        if hex.len() == 6 {
            let r = u8::from_str_radix(&hex[0..2], 16).ok();
            let g = u8::from_str_radix(&hex[2..4], 16).ok();
            let b = u8::from_str_radix(&hex[4..6], 16).ok();
            if let (Some(r), Some(g), Some(b)) = (r, g, b) {
                return Some(Color { r, g, b, a: 255 });
            }
        }
    }
    None
}

fn parse_transform(_transform_str: Option<String>) -> Option<Transform> {
    None
}

pub fn parse_svg(file: BufReader<File>) -> Result<Svg, Box<dyn std::error::Error>> {
    let parser = EventReader::new(file);
    let mut svg_root_option: Option<Svg> = None;
    let mut element_scope_stack: Vec<Vec<SvgElementEnum>> = Vec::new();
    let mut current_text_content = String::new();
    let mut in_text_element = false;

    for e in parser {
        match e {
            Ok(XmlEvent::StartElement { name, attributes, .. }) => {
                let id = attributes.iter().find(|attr| attr.name.local_name == "id").map(|attr| attr.value.clone());
                let style = parse_style(attributes.iter().find(|attr| attr.name.local_name == "style").map(|attr| attr.value.clone()));
                let transform = parse_transform(attributes.iter().find(|attr| attr.name.local_name == "transform").map(|attr| attr.value.clone()));

                match name.local_name.as_str() {
                    "svg" => {
                        let width = get_attr_value(&attributes, "width").unwrap_or_default();
                        let height = get_attr_value(&attributes, "height").unwrap_or_default();
                        let view_box = get_attr_value(&attributes, "viewBox");
                        svg_root_option = Some(Svg { id, width, height, view_box, children: Vec::new(), triples: Vec::new() });
                        element_scope_stack.push(Vec::new());
                    },
                    "g" => {
                        let new_group = Group { id, children: Vec::new(), transform, style, triples: Vec::new() };
                        element_scope_stack.last_mut().unwrap().push(SvgElementEnum::Group(new_group));
                        element_scope_stack.push(Vec::new());
                    },
                    "rect" => {
                        let x = get_attr_f32(&attributes, "x");
                        let y = get_attr_f32(&attributes, "y");
                        let width = get_attr_f32(&attributes, "width");
                        let height = get_attr_f32(&attributes, "height");
                        let rx = get_attr_f32(&attributes, "rx");
                        let ry = get_attr_f32(&attributes, "ry");
                        let rect = Rect { id, x, y, width, height, rx: Some(rx), ry: Some(ry), style, transform, triples: Vec::new() };
                        element_scope_stack.last_mut().unwrap().push(SvgElementEnum::Rect(rect));
                    },
                    "circle" => {
                        let cx = get_attr_f32(&attributes, "cx");
                        let cy = get_attr_f32(&attributes, "cy");
                        let r = get_attr_f32(&attributes, "r");
                        let circle = Circle { id, cx, cy, r, style, transform, triples: Vec::new() };
                        element_scope_stack.last_mut().unwrap().push(SvgElementEnum::Circle(circle));
                    },
                    "ellipse" => {
                        let cx = get_attr_f32(&attributes, "cx");
                        let cy = get_attr_f32(&attributes, "cy");
                        let rx = get_attr_f32(&attributes, "rx");
                        let ry = get_attr_f32(&attributes, "ry");
                        let ellipse = Ellipse { id, cx, cy, rx, ry, style, transform, triples: Vec::new() };
                        element_scope_stack.last_mut().unwrap().push(SvgElementEnum::Ellipse(ellipse));
                    },
                    "text" => {
                        let x = get_attr_f32(&attributes, "x");
                        let y = get_attr_f32(&attributes, "y");
                        current_text_content.clear();
                        in_text_element = true;
                        element_scope_stack.last_mut().unwrap().push(SvgElementEnum::Text(Text { id, x, y, content: String::new(), word_count: 0, style, transform, triples: Vec::new() }));
                    },
                    "tspan" => {
                        in_text_element = true;
                    },
                    "path" => {
                        let d = get_attr_value(&attributes, "d").unwrap_or_default();
                        let approx_bbox = calculate_path_bbox_approx(&d);
                        let path = Path { id, d, style, transform, triples: Vec::new(), approx_bbox };
                        element_scope_stack.last_mut().unwrap().push(SvgElementEnum::Path(path));
                    },
                    _ => {},
                }
            },
            Ok(XmlEvent::EndElement { name }) => {
                match name.local_name.as_str() {
                    "svg" => {
                        if let Some(mut svg) = svg_root_option.take() {
                            svg.children = element_scope_stack.pop().unwrap_or_default();
                            svg_root_option = Some(svg);
                        }
                    },
                    "g" => {
                        let children_of_group = element_scope_stack.pop().unwrap_or_default();
                        if let Some(SvgElementEnum::Group(g)) = element_scope_stack.last_mut().and_then(|vec| vec.last_mut()) {
                            g.children = children_of_group;
                        }
                    },
                    "text" => {
                        if let Some(SvgElementEnum::Text(text_elem)) = element_scope_stack.last_mut().and_then(|vec| vec.last_mut()) {
                            text_elem.content = current_text_content.trim().to_string();
                            text_elem.word_count = text_elem.content.split_whitespace().count();
                        }
                        current_text_content.clear();
                        in_text_element = false;
                    },
                    "tspan" => {},
                    _ => {},
                }
            },
            Ok(XmlEvent::Characters(s)) => {
                if in_text_element {
                    current_text_content.push_str(&s);
                }
            },
            Err(e) => {
                println!("Error: {}", e);
                return Err(e.into());
            },
            _ => {},
        }
    }

    svg_root_option.ok_or_else(|| "No SVG root element found".into())
}