use std::env;
use std::fs::{File, write};
use std::io::BufReader;
use xml::reader::{EventReader, XmlEvent};

use monster_svg_morphism::types::{
    Svg, SvgElementEnum, Rect, Circle, Group, Text, Path, Ellipse,
    BoundingBox, Color, Transform, Style, MonsterElementKind,
};
use monster_svg_morphism::traits::{MapsToMonster};
use monster_svg_morphism::analysis; // Import the analysis module

// The Monster Group primes
const MONSTER_PRIMES: [u64; 15] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71];

fn parse_primes_arg(s: &str) -> Result<Vec<u64>, String> {
    s.split(',')
        .map(|s| s.trim().parse::<u64>())
        .collect::<Result<Vec<u64>, _>>()
        .map_err(|e| format!("Failed to parse prime number: {}", e))
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    let mut hecke_amplify_enabled = false;
    let mut input_path_idx = 1;

    // Check for --analyze flag
    if args.len() > 1 && args[1] == "--analyze" {
        let current_dir = env::current_dir()?;
        println!("Running analysis on: {}", current_dir.display());

        let mut primes_to_analyze_vec = Vec::new();
        let primes_arg_start_idx = 2; // Start checking from argument after --analyze

        if args.len() > primes_arg_start_idx && args[primes_arg_start_idx] == "--primes" {
            if args.len() > primes_arg_start_idx + 1 {
                match parse_primes_arg(&args[primes_arg_start_idx + 1]) {
                    Ok(primes) => primes_to_analyze_vec = primes,
                    Err(e) => {
                        eprintln!("Error parsing --primes argument: {}", e);
                        return Err("Invalid --primes argument".into());
                    }
                }
            } else {
                eprintln!("Error: --primes argument requires a comma-separated list of numbers.");
                return Err("Missing value for --primes".into());
            }
        }

        // If no primes were provided via --primes, use MONSTER_PRIMES as default
        let primes_to_analyze: &[u64] = if primes_to_analyze_vec.is_empty() {
            &MONSTER_PRIMES
        } else {
            &primes_to_analyze_vec
        };

        let report = analysis::run_analysis(&current_dir, primes_to_analyze);

        println!("\n--- Prime Resonance Analysis Report ---");
        if report.prime_occurrences.is_empty() {
            println!("No prime resonances found.");
        } else {
            // Sort primes for consistent output
            let mut sorted_primes: Vec<u64> = report.prime_occurrences.keys().cloned().collect();
            sorted_primes.sort_unstable();
            for prime in sorted_primes {
                if let Some(occurrences) = report.prime_occurrences.get(&prime) {
                    println!("Prime {}:", prime);
                    for occ in occurrences {
                        println!("  - {}", occ);
                    }
                }
            }
        }


        println!("\n--- Prime Factor Occurrences in Literals and String ASCII Sums ---");
        if report.prime_factor_occurrences.is_empty() {
            println!("No prime factor occurrences found.");
        } else {
            let mut sorted_factors: Vec<u64> = report.prime_factor_occurrences.keys().cloned().collect();
            sorted_factors.sort_unstable();
            for factor in sorted_factors {
                if let Some(occurrences) = report.prime_factor_occurrences.get(&factor) {
                    println!("Prime Factor {}:", factor);
                    for occ in occurrences {
                        println!("  - {}", occ);
                    }
                }
            }
        }

        println!("\n--- Recursive Cycles ---");
        if report.recursive_cycles.is_empty() {
            println!("No recursive cycles with configured prime lengths found.");
        } else {
            for (start_node, cycle) in report.recursive_cycles {
                println!("- Cycle starting at '{}' with length {}: {:?}", start_node, cycle.len(), cycle);
            }
        }

        println!("\n--- Symbol Table (Path to PrimeVector Embedding) ---");
        if report.symbol_table.is_empty() {
            println!("No symbolic embeddings generated.");
        } else {
            let mut sorted_paths: Vec<String> = report.symbol_table.keys().cloned().collect();
            sorted_paths.sort_unstable();
            for path in sorted_paths {
                if let Some(prime_vector) = report.symbol_table.get(&path) {
                    println!("Path: {}", path);
                    // Sort primes within the vector for consistent output
                    let mut sorted_primes: Vec<u64> = prime_vector.map.keys().cloned().collect();
                    sorted_primes.sort_unstable();
                    for prime in sorted_primes {
                        if let Some(coeff) = prime_vector.map.get(&prime) {
                            println!("  Prime {}: Coefficient {}", prime, coeff);
                        }
                    }
                }
            }
        }
        
        println!("\n--- Composite Prime Vectors (Conceptual Multiplication) ---");
        if report.composite_prime_vectors.is_empty() {
            println!("No composite prime vectors generated.");
        } else {
            let mut sorted_paths: Vec<String> = report.composite_prime_vectors.keys().cloned().collect();
            sorted_paths.sort_unstable();
            for path in sorted_paths {
                if let Some(prime_vector) = report.composite_prime_vectors.get(&path) {
                    println!("Parent Path: {}", path);
                    let mut sorted_primes: Vec<u64> = prime_vector.map.keys().cloned().collect();
                    sorted_primes.sort_unstable();
                    for prime in sorted_primes {
                        if let Some(coeff) = prime_vector.map.get(&prime) {
                            println!("  Prime {}: Coefficient {}", prime, coeff);
                        }
                    }
                }
            }
        }
        return Ok(())
    }

    // Check for --hecke-amplify flag
    // The flag can be at position 1 or 2 (if input_path_idx is already advanced by --analyze)
    if args.len() > 1 {
        if args[1] == "--hecke-amplify" {
            hecke_amplify_enabled = true;
            input_path_idx = 2; // Input path will be at index 2
        } else if args.len() > 2 && args[2] == "--hecke-amplify" {
            hecke_amplify_enabled = true;
            // input_path_idx remains 1 as --hecke-amplify is after input.svg
        }
    }


    if args.len() < input_path_idx + 2 { // Need at least input and output paths
        eprintln!("Usage: {} [--hecke-amplify] <input.svg> <output.svg>", args[0]);
        eprintln!("       {} --analyze", args[0]);
        return Err("Invalid arguments".into());
    }
    
    let input_path = &args[input_path_idx];
    let output_path = &args[input_path_idx + 1];

    let file = File::open(input_path)?;
    let file = BufReader::new(file);

    let mut svg_root = parse_svg(file)?;

    apply_morphism(&mut svg_root, hecke_amplify_enabled);

    let output_svg_string = svg_root.to_svg_string();
    write(output_path, output_svg_string)?;

    println!("Successfully generated morphed SVG at {}", output_path);
    if hecke_amplify_enabled {
        println!("Applied Hecke-like amplification for P71_1 elements.");
    }

    Ok(())
}

fn parse_svg(file: BufReader<File>) -> Result<Svg, Box<dyn std::error::Error>> {
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

fn apply_morphism(svg: &mut Svg, hecke_amplify: bool) {
    for child in &mut svg.children {
        apply_morphism_to_element(child, hecke_amplify);
    }
}

fn apply_morphism_to_element(element: &mut SvgElementEnum, hecke_amplify: bool) {
    let monster_kind = element.map_to_monster_element();
    let new_color = monster_color(&monster_kind);

    if hecke_amplify && monster_kind == MonsterElementKind::P71_1 {
        apply_hecke_effect(element);
    }

    let style = match element {
        SvgElementEnum::Rect(e) => &mut e.style,
        SvgElementEnum::Circle(e) => &mut e.style,
        SvgElementEnum::Ellipse(e) => &mut e.style,
        SvgElementEnum::Group(e) => {
            for child in &mut e.children {
                apply_morphism_to_element(child, hecke_amplify);
            }
            &mut e.style
        },
        SvgElementEnum::Text(e) => &mut e.style,
        SvgElementEnum::Path(e) => &mut e.style,
    };

    if style.is_none() {
        *style = Some(Style { fill: None, stroke: None, stroke_width: None });
    }
    if let Some(s) = style {
        s.fill = Some(new_color);
    }
}

fn apply_hecke_effect(element: &mut SvgElementEnum) {
    match element {
        SvgElementEnum::Rect(e) => {
            e.width *= 2.0;
            e.height *= 2.0;
            // Adjust position to keep center somewhat
            e.x -= e.width / 4.0;
            e.y -= e.height / 4.0;
        },
        SvgElementEnum::Circle(e) => {
            e.r *= 2.0;
        },
        SvgElementEnum::Ellipse(e) => {
            e.rx *= 2.0;
            e.ry *= 2.0;
        },
        SvgElementEnum::Text(e) => {
            // For text, just make it a distinct color for visibility for now
            if e.style.is_none() {
                e.style = Some(Style { fill: None, stroke: None, stroke_width: None });
            }
            if let Some(s) = &mut e.style {
                s.fill = Some(Color { r: 255, g: 255, b: 0, a: 255 }); // Bright yellow
            }
        },
        SvgElementEnum::Path(e) => {
            // Scaling path data is complex, for now, just change color
            if e.style.is_none() {
                e.style = Some(Style { fill: None, stroke: None, stroke_width: None });
            }
            if let Some(s) = &mut e.style {
                s.fill = Some(Color { r: 0, g: 255, b: 255, a: 255 }); // Cyan
            }
        },
        SvgElementEnum::Group(e) => {
            // Recursively apply to children
            for child in &mut e.children {
                apply_hecke_effect(child);
            }
        }
    }
}

fn monster_color(kind: &MonsterElementKind) -> Color {
    match kind {
        MonsterElementKind::P2_46 => Color { r: 255, g: 0, b: 0, a: 255 },
        MonsterElementKind::P3_20 => Color { r: 0, g: 255, b: 0, a: 255 },
        MonsterElementKind::P5_9 => Color { r: 0, g: 0, b: 255, a: 255 },
        MonsterElementKind::P7_6 => Color { r: 255, g: 255, b: 0, a: 255 },
        MonsterElementKind::P11_2 => Color { r: 255, g: 0, b: 255, a: 255 },
        MonsterElementKind::P13_3 => Color { r: 0, g: 255, b: 255, a: 255 },
        MonsterElementKind::P17_1 => Color { r: 128, g: 0, b: 0, a: 255 },
        MonsterElementKind::P19_1 => Color { r: 0, g: 128, b: 0, a: 255 },
        MonsterElementKind::P23_1 => Color { r: 0, g: 0, b: 128, a: 255 },
        MonsterElementKind::P29_1 => Color { r: 128, g: 128, b: 0, a: 255 },
        MonsterElementKind::P31_1 => Color { r: 128, g: 0, b: 128, a: 255 },
        MonsterElementKind::P41_1 => Color { r: 0, g: 128, b: 128, a: 255 },
        MonsterElementKind::P47_1 => Color { r: 128, g: 128, b: 128, a: 255 },
        MonsterElementKind::P59_1 => Color { r: 255, g: 128, b: 0, a: 255 },
        MonsterElementKind::P71_1 => Color { r: 255, g: 0, b: 128, a: 255 },
        MonsterElementKind::Unknown => Color { r: 0, g: 0, b: 0, a: 255 },
        MonsterElementKind::TextOnePart => Color { r: 200, g: 200, b: 200, a: 255 },
        MonsterElementKind::TextTwoParts => Color { r: 150, g: 150, b: 150, a: 255 },
        MonsterElementKind::TextThreeParts => Color { r: 100, g: 100, b: 100, a: 255 },
        MonsterElementKind::ExternalSystem => Color { r: 50, g: 50, b: 50, a: 255 },
    }
}

// --- SVG Generation ---

trait ToSvgString {
    fn to_svg_string(&self) -> String;
}

impl ToSvgString for Svg {
    fn to_svg_string(&self) -> String {
        let children_str: String = self.children.iter().map(|c| c.to_svg_string()).collect();
        format!(r##"<svg width="{}" height="{}" viewBox="{}" xmlns="http://www.w3.org/2000/svg">{}</svg>"##,
            self.width, self.height, self.view_box.as_deref().unwrap_or(""), children_str)
    }
}

impl ToSvgString for SvgElementEnum {
    fn to_svg_string(&self) -> String {
        match self {
            SvgElementEnum::Rect(e) => e.to_svg_string(),
            SvgElementEnum::Circle(e) => e.to_svg_string(),
            SvgElementEnum::Ellipse(e) => e.to_svg_string(),
            SvgElementEnum::Group(e) => e.to_svg_string(),
            SvgElementEnum::Text(e) => e.to_svg_string(),
            SvgElementEnum::Path(e) => e.to_svg_string(),
        }
    }
}

impl ToSvgString for Rect {
    fn to_svg_string(&self) -> String {
        format!(r##"<rect x="{}" y="{}" width="{}" height="{}" {} />"##,
            self.x, self.y, self.width, self.height, self.style.as_ref().map_or(String::new(), |s| s.to_svg_string()))
    }
}

impl ToSvgString for Circle {
    fn to_svg_string(&self) -> String {
        format!(r##"<circle cx="{}" cy="{}" r="{}" {} />"##,
            self.cx, self.cy, self.r, self.style.as_ref().map_or(String::new(), |s| s.to_svg_string()))
    }
}

impl ToSvgString for Ellipse {
    fn to_svg_string(&self) -> String {
        format!(r##"<ellipse cx="{}" cy="{}" rx="{}" ry="{}" {} />"##,
            self.cx, self.cy, self.rx, self.ry, self.style.as_ref().map_or(String::new(), |s| s.to_svg_string()))
    }
}

impl ToSvgString for Group {
    fn to_svg_string(&self) -> String {
        let children_str: String = self.children.iter().map(|c| c.to_svg_string()).collect();
        format!(r##"<g {}>{}</g>"##,
            self.style.as_ref().map_or(String::new(), |s| s.to_svg_string()), children_str)
    }
}

impl ToSvgString for Text {
    fn to_svg_string(&self) -> String {
        format!(r##"<text x="{}" y="{}" {}>{}</text>"##,
            self.x, self.y, self.style.as_ref().map_or(String::new(), |s| s.to_svg_string()), self.content)
    }
}

impl ToSvgString for Path {
    fn to_svg_string(&self) -> String {
        format!(r##"<path d="{}" {} />"##,
            self.d, self.style.as_ref().map_or(String::new(), |s| s.to_svg_string()))
    }
}

impl ToSvgString for Style {
    fn to_svg_string(&self) -> String {
        let mut style_parts = Vec::new();
        if let Some(fill) = &self.fill {
            style_parts.push(format!("fill:{}", fill.to_svg_string()));
        }
        if let Some(stroke) = &self.stroke {
            style_parts.push(format!("stroke:{}", stroke.to_svg_string()));
        }
        if let Some(stroke_width) = self.stroke_width {
            style_parts.push(format!("stroke-width:{}", stroke_width));
        }
        format!("style=\"{}\"", style_parts.join(";"))
    }
}

impl ToSvgString for Color {
    fn to_svg_string(&self) -> String {
        format!("#{:02x}{:02x}{:02x}", self.r, self.g, self.b)
    }
}

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
