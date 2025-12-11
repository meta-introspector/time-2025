use crate::types::bounding_box::BoundingBox;
use crate::types::bsp_node::{BspNode}; // BspSplitAxis is also used here
use crate::types::bsp_split_axis::BspSplitAxis;
use crate::types::svg_element_enum::SvgElementEnum;
use crate::traits::svg_component::SvgComponent; // Used for bounding_box()

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
        all_elements: Vec<SvgElementEnum>,
        max_depth: usize,
        current_depth: usize,
    ) {
        if current_depth >= max_depth || all_elements.is_empty() {
            node.elements = all_elements;
            return;
        }

        let split_axis = if current_depth % 2 == 0 { BspSplitAxis::X } else { BspSplitAxis::Y };
        let split_point = match split_axis {
            BspSplitAxis::X => node.bbox.x + node.bbox.width / 2.0,
            BspSplitAxis::Y => node.bbox.y + node.bbox.height / 2.0,
        };

        node.split = Some((split_axis.clone(), split_point));

        let mut left_elements = Vec::new();
        let mut right_elements = Vec::new();
        let mut current_node_elements = Vec::new();

        for element in all_elements {
            let element_bbox = element.bounding_box();

            let (goes_left, goes_right) = match split_axis {
                BspSplitAxis::X => (
                    (element_bbox.x + element_bbox.width) <= split_point,
                    element_bbox.x >= split_point,
                ),
                BspSplitAxis::Y => (
                    (element_bbox.y + element_bbox.height) <= split_point,
                    element_bbox.y >= split_point,
                ),
            };

            if goes_left && !goes_right {
                left_elements.push(element);
            } else if goes_right && !goes_left {
                right_elements.push(element);
            } else {
                current_node_elements.push(element);
            }
        }

        node.elements = current_node_elements;

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

        if !left_elements.is_empty() {
            let mut left_node = BspNode::new(left_bbox, current_depth + 1);
            Self::build_recursive(&mut left_node, left_elements, max_depth, current_depth + 1);
            node.left_child = Some(Box::new(left_node));
        }

        if !right_elements.is_empty() {
            let mut right_node = BspNode::new(right_bbox, current_depth + 1);
            Self::build_recursive(&mut right_node, right_elements, max_depth, current_depth + 1);
            node.right_child = Some(Box::new(right_node));
        }
    }

    pub fn build(&mut self, elements: Vec<SvgElementEnum>) {
        Self::build_recursive(&mut self.root, elements, self.max_depth, 0);
    }
}
