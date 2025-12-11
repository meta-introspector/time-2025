use crate::types::bounding_box::BoundingBox;
use crate::types::svg_element_enum::SvgElementEnum;
use crate::types::bsp_split_axis::BspSplitAxis;

#[derive(Debug, Clone, PartialEq)]
pub struct BspNode {
    pub bbox: BoundingBox,
    pub elements: Vec<SvgElementEnum>,
    pub split: Option<(BspSplitAxis, f32)>,
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
