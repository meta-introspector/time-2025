// monster_svg_morphism/src/lib.rs

/// Represents the symbolic 'elements' of the Monster Group,
/// conceptualized as 15 distinct archetypes that SVG traits might map to.
/// The specific prime powers are taken from the user's description and
/// extended to reach 15 for a complete symbolic representation.
///
/// Each kind is meant to 'capture' a specific structural aspect or pattern
/// within the SVG document, as described by the user.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum MonsterElementKind {
    /// Captures a global structural division of the document, possibly related
    /// to a 46-layer binary tree partitioning (BSP).
    P2_46,  // 2^46
    /// Captures elements related to a '20 triples' encoding scheme.
    P3_20,  // 3^20
    /// Captures elements related to a '9-fold' or highly recursive structure (e.g., groups with 9 children).
    P5_9,   // 5^9
    /// Captures elements with 6 distinct states or symmetries (e.g., groups with 6 children).
    P7_6,   // 7^6
    /// Captures elements with 11 distinct sub-components or dual nature (e.g., groups with 11 children).
    P11_2,  // 11^2
    /// Captures elements with 13 distinct sub-components or triple nature (e.g., groups with 13 children).
    P13_3,  // 13^3
    /// Captures single, prominent elements, perhaps a key node (e.g., text '11').
    P17_1,  // 17^1 (Prime 17)
    /// Captures single, prominent elements, perhaps a key node (e.g., text '17').
    P19_1,  // 19^1 (Prime 19)
    /// Captures single, prominent elements, perhaps a key node (e.g., text '19').
    P23_1,  // 23^1 (Prime 23)
    /// Captures the 'shell' or boundary of a section, related to the spiral and text '23'.
    P29_1,  // 29^1 (Prime 29)
    /// Captures basic rectangular structures.
    P31_1,  // 31^1 (Prime 31)
    /// Captures complex path data or curvilinear forms.
    P41_1,  // 41^1 (Prime 41)
    /// Captures a specific structural pattern, replacing previous P37_1. (e.g., circular/elliptical shapes)
    P47_1,  // 47^1 (Prime 47) - Corrected from 37
    /// Captures hierarchical grouping or nested structures, replacing previous P43_1. (e.g., groups not matching specific child counts)
    P59_1,  // 59^1 (Prime 59) - Corrected from 43
    /// Captures the overall document structure or a dominant element (e.g., text '71', or SVG root), representing 71 facets.
    P71_1,  // 71^1 (Prime 71)
    /// Represents an element that does not cleanly map to any defined MonsterElementKind.
    /// These may be 'residuals' or 'exceptions' as described by the user.
    Unknown,
    /// Represents text elements with 1 part (single word).
    TextOnePart,
    /// Represents text elements with 2 parts, forming a 'two rule'.
    TextTwoParts,
    /// Represents text elements with 3 parts, forming a 'three rule'.
    TextThreeParts,
    /// Represents an external system or project (like AWS, GitHub, GCC), which are 'Monster Systems' themselves.
    /// This is a special mapping for text content that refers to such external systems.
    ExternalSystem,
}

/// A trait for any Rust structure that represents an SVG component or element.
/// This trait will define common behaviors or properties expected from all SVG-related types.
pub trait SvgComponent {
    /// Returns a unique identifier for the SVG component instance.
    fn id(&self) -> Option<&str>;

    /// Calculates and returns the local bounding box of the component.
    /// This does not account for parent transforms.
    fn bounding_box(&self) -> BoundingBox;

    /// Returns a measure of the component's size (e.g., area for 2D shapes).
    fn size(&self) -> f32;
}

/// A trait that defines how an SVG component maps to a Monster Group element.
/// This is the core of the f(x) -> M function.
pub trait MapsToMonster {
    /// Determines which `MonsterElementKind` this SVG component maps to.
    /// This mapping should consider the 'traits' and structural properties
    /// of the SVG element as it relates to the 'blueprint' of the Monster Group elements.
    fn map_to_monster_element(&self) -> MonsterElementKind;
}

// --- Basic SVG Building Blocks (Structs and Enums) ---

/// Represents an RDF-like triple for classifying and relating objects.
#[derive(Debug, Clone, PartialEq)]
pub struct Triple {
    pub subject: String,
    pub predicate: String,
    pub object: String,
}


/// Represents a 2D point.
#[derive(Debug, Clone, PartialEq)]
pub struct Point {
    pub x: f32,
    pub y: f32,
}

/// Represents a rectangular bounding box.
#[derive(Debug, Clone, PartialEq)]
pub struct BoundingBox {
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
}

impl BoundingBox {
    pub fn new(x: f32, y: f32, width: f32, height: f32) -> Self {
        BoundingBox { x, y, width, height }
    }

    pub fn area(&self) -> f32 {
        self.width * self.height
    }

    /// Checks if another bounding box is fully contained within this one.
    pub fn contains(&self, other: &BoundingBox) -> bool {
        other.x >= self.x &&
        other.y >= self.y &&
        (other.x + other.width) <= (self.x + self.width) &&
        (other.y + other.height) <= (self.y + self.height)
    }

    /// Checks if two bounding boxes overlap.
    pub fn overlaps(&self, other: &BoundingBox) -> bool {
        self.x < (other.x + other.width) &&
        (self.x + self.width) > other.x &&
        self.y < (other.y + other.height) &&
        (self.y + self.height) > other.y
    }
}


/// Represents a color, e.g., RGB.
#[derive(Debug, Clone, PartialEq)]
pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8, // Alpha channel
}

/// Represents a transformation matrix.
#[derive(Debug, Clone, PartialEq)]
pub struct Transform {
    pub a: f32, pub b: f32,
    pub c: f32, pub d: f32,
    pub e: f32, pub f: f32,
}

/// Represents common styling attributes.
#[derive(Debug, Clone, PartialEq)]
pub struct Style {
    pub fill: Option<Color>,
    pub stroke: Option<Color>,
    pub stroke_width: Option<f32>,
    // Add more style attributes as needed
}

/// Represents an SVG Rectangle element.
#[derive(Debug, Clone, PartialEq)]
pub struct Rect {
    pub id: Option<String>,
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
    pub rx: Option<f32>, // Rounded x-corner
    pub ry: Option<f32>, // Rounded y-corner
    pub style: Option<Style>,
    pub transform: Option<Transform>,
    pub triples: Vec<Triple>, // Associated RDF-like triples
}

impl SvgComponent for Rect {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        BoundingBox::new(self.x, self.y, self.width, self.height)
    }

    fn size(&self) -> f32 {
        self.bounding_box().area()
    }
}

impl MapsToMonster for Rect {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        // Mapping based on capturing basic rectangular structures.
        // If it has triples, it might map to P3_20 if it has 20 triples or is central to an idea
        if self.triples.len() > 0 {
            // Placeholder: A more sophisticated rule would check *what* the triples are.
            MonsterElementKind::P3_20
        } else {
            MonsterElementKind::P31_1
        }
    }
}


/// Represents an SVG Circle element.
#[derive(Debug, Clone, PartialEq)]
pub struct Circle {
    pub id: Option<String>,
    pub cx: f32,
    pub cy: f32,
    pub r: f32,
    pub style: Option<Style>,
    pub transform: Option<Transform>,
    pub triples: Vec<Triple>, // Associated RDF-like triples
}

impl SvgComponent for Circle {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        BoundingBox::new(self.cx - self.r, self.cy - self.r, self.r * 2.0, self.r * 2.0)
    }

    fn size(&self) -> f32 {
        std::f32::consts::PI * self.r * self.r // Area of circle
    }
}

impl MapsToMonster for Circle {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        // Mapping based on capturing circular or radial structures.
        if self.triples.len() > 0 {
            MonsterElementKind::P3_20
        } else {
            MonsterElementKind::P47_1 // Corrected from P37_1
        }
    }
}

/// Represents an SVG Ellipse element.
#[derive(Debug, Clone, PartialEq)]
pub struct Ellipse {
    pub id: Option<String>,
    pub cx: f32,
    pub cy: f32,
    pub rx: f32,
    pub ry: f32,
    pub style: Option<Style>,
    pub transform: Option<Transform>,
    pub triples: Vec<Triple>, // Associated RDF-like triples
}

impl SvgComponent for Ellipse {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        BoundingBox::new(self.cx - self.rx, self.cy - self.ry, self.rx * 2.0, self.ry * 2.0)
    }

    fn size(&self) -> f32 {
        std::f32::consts::PI * self.rx * self.ry // Area of ellipse
    }
}

impl MapsToMonster for Ellipse {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        // Example mapping for Ellipse
        if self.triples.len() > 0 {
            MonsterElementKind::P3_20
        } else {
            MonsterElementKind::P47_1 // Corrected from P37_1, sharing with Circle for now
        }
    }
}


/// Represents an SVG Group element, which can contain other SVG components.
#[derive(Debug, Clone, PartialEq)]
pub struct Group {
    pub id: Option<String>,
    pub children: Vec<SvgElementEnum>, // Use an enum to hold various SVG elements
    pub transform: Option<Transform>,
    pub style: Option<Style>, // Group style simplified to Option<Style>
    pub triples: Vec<Triple>, // Associated RDF-like triples
}

impl SvgComponent for Group {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        // This is a simplified bounding box for a group, just covering its children.
        // A more accurate one would apply transforms and combine child bounding boxes.
        let mut min_x = f32::MAX;
        let mut min_y = f32::MAX;
        let mut max_x = f32::MIN;
        let mut max_y = f32::MIN;

        if self.children.is_empty() {
            return BoundingBox::new(0.0, 0.0, 0.0, 0.0);
        }

        for child in &self.children {
            let child_bbox = child.bounding_box();
            min_x = min_x.min(child_bbox.x);
            min_y = min_y.min(child_bbox.y);
            max_x = max_x.max(child_bbox.x + child_bbox.width);
            max_y = max_y.max(child_bbox.y + child_bbox.height);
        }

        BoundingBox::new(min_x, min_y, max_x - min_x, max_y - min_y)
    }

    fn size(&self) -> f32 {
        self.bounding_box().area()
    }
}

impl MapsToMonster for Group {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        // Mapping based on capturing hierarchical grouping or nested structures.
        if self.triples.len() > 0 {
            return MonsterElementKind::P3_20;
        }

        match self.children.len() {
            9 => MonsterElementKind::P5_9,   // "9-fold/recursive structure"
            6 => MonsterElementKind::P7_6,   // "6 states/symmetries"
            11 => MonsterElementKind::P11_2, // "11 sub-components/dual nature"
            13 => MonsterElementKind::P13_3, // "13 sub-components/triple nature"
            _ => MonsterElementKind::P59_1,  // Default for other groups
        }
    }
}

/// Represents an SVG Text element.
#[derive(Debug, Clone, PartialEq)]
pub struct Text {
    pub id: Option<String>,
    pub x: f32,
    pub y: f32,
    pub content: String,
    pub word_count: usize, // New field for word count
    pub style: Option<Style>,
    pub transform: Option<Transform>,
    pub triples: Vec<Triple>, // Associated RDF-like triples
    // Other attributes like font-size, font-family, etc.
}

impl SvgComponent for Text {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        // Simplified bounding box for text. In reality, it depends on font, size, etc.
        // For now, approximate as a small square at (x,y)
        // A better approach would be to parse font-size and approximate width based on content length
        let char_width_approx = 5.0; // Approximation for character width in pixels/units
        let char_height_approx = 10.0; // Approximation for character height
        let width = self.content.len() as f32 * char_width_approx;
        let height = char_height_approx;
        BoundingBox::new(self.x, self.y - height, width, height) // Adjust y to be baseline
    }

    fn size(&self) -> f32 {
        self.bounding_box().area()
    }
}

impl MapsToMonster for Text {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        // Mapping based on numerical content, reflecting single, prominent elements.
        if self.triples.len() > 0 {
            return MonsterElementKind::P3_20;
        }

        match self.content.as_str() {
            "0" => MonsterElementKind::P2_46,
            "1" => MonsterElementKind::P3_20, // If '1' is special for 20 triples
            "2" => MonsterElementKind::P5_9,
            "3" => MonsterElementKind::P7_6,
            "5" => MonsterElementKind::P11_2,
            "7" => MonsterElementKind::P13_3,
            "11" => MonsterElementKind::P17_1,
            "17" => MonsterElementKind::P19_1,
            "19" => MonsterElementKind::P23_1,
            "23" => MonsterElementKind::P29_1, // "shell stops at 23, the spiral"
            "71" => MonsterElementKind::P71_1, // "71 facets of the system"
            // External systems / Projects as specific MonsterElementKinds
            "aws" | "github" | "ssm" | "gcc" | "qemu" | "docker" | "k8s" | "systemd" => MonsterElementKind::ExternalSystem, // Map to new ExternalSystem kind
            _ => {
                // New rules for unmatched text based on word count
                match self.word_count {
                    1 => MonsterElementKind::TextOnePart,
                    2 => MonsterElementKind::TextTwoParts,
                    3 => MonsterElementKind::TextThreeParts,
                    _ => MonsterElementKind::Unknown, // Default for other text or unmapped numbers/word counts
                }
            }
        }
    }
}

/// Represents an SVG Path element.
#[derive(Debug, Clone, PartialEq)]
pub struct Path {
    pub id: Option<String>,
    pub d: String, // Path data string
    pub style: Option<Style>,
    pub transform: Option<Transform>,
    pub triples: Vec<Triple>, // Associated RDF-like triples
    // This bounding box is a placeholder. Accurate path bounding box calculation is complex.
    pub approx_bbox: BoundingBox,
}

impl SvgComponent for Path {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        self.approx_bbox.clone() // Return the approximate bounding box
    }

    fn size(&self) -> f32 {
        self.bounding_box().area()
    }
}

impl MapsToMonster for Path {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        if self.triples.len() > 0 {
            return MonsterElementKind::P3_20;
        }
        // The spiral path is a key structural element.
        if self.id.as_deref() == Some("path382") { // ID of the spiral path
            MonsterElementKind::P29_1 // Map the spiral to the shell/boundary element
        } else {
            // Other paths might capture complex curvilinear forms.
            MonsterElementKind::P41_1
        }
    }
}


/// An enum to hold any of the possible SVG elements, allowing for heterogeneous collections.
#[derive(Debug, Clone, PartialEq)]
pub enum SvgElementEnum {
    Rect(Rect),
    Circle(Circle),
    Ellipse(Ellipse),
    Group(Group),
    Text(Text),
    Path(Path),
    // Add other SVG elements here
}

// Blanket implementation for SvgComponent for SvgElementEnum
impl SvgComponent for SvgElementEnum {
    fn id(&self) -> Option<&str> {
        match self {
            SvgElementEnum::Rect(r) => r.id(),
            SvgElementEnum::Circle(c) => c.id(),
            SvgElementEnum::Ellipse(e) => e.id(),
            SvgElementEnum::Group(g) => g.id(),
            SvgElementEnum::Text(t) => t.id(),
            SvgElementEnum::Path(p) => p.id(),
        }
    }

    fn bounding_box(&self) -> BoundingBox {
        match self {
            SvgElementEnum::Rect(r) => r.bounding_box(),
            SvgElementEnum::Circle(c) => c.bounding_box(),
            SvgElementEnum::Ellipse(e) => e.bounding_box(),
            SvgElementEnum::Group(g) => g.bounding_box(),
            SvgElementEnum::Text(t) => t.bounding_box(),
            SvgElementEnum::Path(p) => p.bounding_box(),
        }
    }

    fn size(&self) -> f32 {
        match self {
            SvgElementEnum::Rect(r) => r.size(),
            SvgElementEnum::Circle(c) => c.size(),
            SvgElementEnum::Ellipse(e) => e.size(),
            SvgElementEnum::Group(g) => g.size(),
            SvgElementEnum::Text(t) => t.size(),
            SvgElementEnum::Path(p) => p.size(),
        }
    }
}

// Blanket implementation for MapsToMonster for SvgElementEnum
impl MapsToMonster for SvgElementEnum {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        match self {
            SvgElementEnum::Rect(r) => r.map_to_monster_element(),
            SvgElementEnum::Circle(c) => c.map_to_monster_element(),
            SvgElementEnum::Ellipse(e) => e.map_to_monster_element(),
            SvgElementEnum::Group(g) => g.map_to_monster_element(),
            SvgElementEnum::Text(t) => t.map_to_monster_element(),
            SvgElementEnum::Path(p) => p.map_to_monster_element(),
        }
    }
}


/// The root of the SVG structure.
#[derive(Debug, Clone, PartialEq)]
pub struct Svg {
    pub id: Option<String>,
    pub width: String,
    pub height: String,
    pub view_box: Option<String>, // "0 0 width height"
    pub children: Vec<SvgElementEnum>,
    pub triples: Vec<Triple>, // Associated RDF-like triples
}

impl SvgComponent for Svg {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        // Simplified bounding box for the SVG element, based on its children
        // or its width/height attributes if available.
        let mut min_x = f32::MAX;
        let mut min_y = f32::MAX;
        let mut max_x = f32::MIN;
        let mut max_y = f32::MIN;

        if self.children.is_empty() {
            // Fallback to width/height if no children
            let width = self.width.parse::<f32>().unwrap_or_default();
            let height = self.height.parse::<f32>().unwrap_or_default();
            return BoundingBox::new(0.0, 0.0, width, height);
        }

        for child in &self.children {
            let child_bbox = child.bounding_box();
            min_x = min_x.min(child_bbox.x);
            min_y = min_y.min(child_bbox.y);
            max_x = max_x.max(child_bbox.x + child_bbox.width);
            max_y = max_y.max(child_bbox.y + child_bbox.height);
        }

        BoundingBox::new(min_x, min_y, max_x - min_x, max_y - min_y)
    }

    fn size(&self) -> f32 {
        self.bounding_box().area()
    }
}

impl MapsToMonster for Svg {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        if self.triples.len() > 0 {
            MonsterElementKind::P3_20
        } else {
            // The root SVG element maps to P71_1, capturing the overall document structure (71 facets).
            MonsterElementKind::P71_1
        }
    }
}

// --- Placeholder for BSP structure ---
#[derive(Debug, Clone, PartialEq)]
pub enum BspSplitAxis {
    X,
    Y,
}

#[derive(Debug, Clone, PartialEq)]
pub struct BspNode {
    pub bbox: BoundingBox,
    pub elements: Vec<SvgElementEnum>, // Elements contained directly in this node
    pub split: Option<(BspSplitAxis, f32)>, // Axis and position of the split
    pub left_child: Option<Box<BspNode>>,
    pub right_child: Option<Box<BspNode>>,
    pub depth: usize,
}

impl BspNode {
    pub fn new(bbox: BoundingBox, depth: usize) -> Self {
        BspNode {
            bbox,
            elements: Vec::new(),
            split: None,
            left_child: None,
            right_child: None,
            depth,
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct BspTree {
    pub root: BspNode,
    pub max_depth: usize,
}

impl BspTree {
    pub fn new(document_bbox: BoundingBox, max_depth: usize) -> Self {
        BspTree {
            root: BspNode::new(document_bbox, 0),
            max_depth,
        }
    }

    /// Recursively builds the BSP tree by spatially partitioning the elements.
    ///
    /// The BSP tree is built to a maximum depth, alternating splitting axes.
    /// Elements are distributed into child nodes if they are fully contained.
    /// Elements that span a split or are not fully contained by a child node
    /// remain in the parent node's `elements` list.
    pub fn build_recursive(
        node: &mut BspNode,
        all_elements: Vec<SvgElementEnum>, // Elements to consider for this node and its children
        max_depth: usize,
        current_depth: usize,
    ) {
        if current_depth >= max_depth || all_elements.is_empty() {
            node.elements = all_elements; // All remaining elements stay in this leaf node
            return;
        }

        // Determine split axis: alternate X and Y
        let split_axis = if current_depth % 2 == 0 { BspSplitAxis::X } else { BspSplitAxis::Y };

        // Determine split point (midpoint of the current node's bounding box)
        let split_point = match split_axis {
            BspSplitAxis::X => node.bbox.x + node.bbox.width / 2.0,
            BspSplitAxis::Y => node.bbox.y + node.bbox.height / 2.0,
        };

        node.split = Some((split_axis.clone(), split_point));

        let mut left_elements = Vec::new();
        let mut right_elements = Vec::new();
        let mut current_node_elements = Vec::new(); // Elements that cannot be cleanly put into children

        for element in all_elements {
            let element_bbox = element.bounding_box();

            let (goes_left, goes_right) = match split_axis {
                BspSplitAxis::X => (
                    (element_bbox.x + element_bbox.width) <= split_point, // Entirely to the left
                    element_bbox.x >= split_point,                       // Entirely to the right
                ),
                BspSplitAxis::Y => (
                    (element_bbox.y + element_bbox.height) <= split_point, // Entirely to the top/left
                    element_bbox.y >= split_point,                       // Entirely to the bottom/right
                ),
            };

            if goes_left && !goes_right { // Element is fully on the left/top side
                left_elements.push(element);
            } else if goes_right && !goes_left { // Element is fully on the right/bottom side
                right_elements.push(element);
            } else { // Element spans the split or is ambiguous, keep it in this node
                current_node_elements.push(element);
            }
        }

        node.elements = current_node_elements;

        // Create bounding boxes for child nodes
        let (left_bbox, right_bbox) = match split_axis {
            BspSplitAxis::X => (
                BoundingBox::new(node.bbox.x, node.bbox.y, node.bbox.width / 2.0, node.bbox.height),
                BoundingBox::new(split_point, node.bbox.y, node.bbox.width / 2.0, node.bbox.height),
            ),
            BspSplitAxis::Y => (
                BoundingBox::new(node.bbox.x, node.bbox.y, node.bbox.width, node.bbox.height / 2.0),
                BoundingBox::new(node.bbox.x, split_point, node.bbox.width, node.bbox.height / 2.0),
            ),
        };

        // Recurse for left child
        if !left_elements.is_empty() {
            let mut left_node = BspNode::new(left_bbox, current_depth + 1);
            Self::build_recursive(&mut left_node, left_elements, max_depth, current_depth + 1);
            node.left_child = Some(Box::new(left_node));
        }

        // Recurse for right child
        if !right_elements.is_empty() {
            let mut right_node = BspNode::new(right_bbox, current_depth + 1);
            Self::build_recursive(&mut right_node, right_elements, max_depth, current_depth + 1);
            node.right_child = Some(Box::new(right_node));
        }
    }
    
    // Public method to start the recursive build
    pub fn build(&mut self, elements: Vec<SvgElementEnum>) {
        Self::build_recursive(&mut self.root, elements, self.max_depth, 0);
    }
}
