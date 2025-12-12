use crate::bounding_box::BoundingBox;
use crate::bsp_node::{BspNode};
use crate::bsp_split_axis::BspSplitAxis;
use crate::svg_element_enum::SvgElementEnum;
use crate::traits::svg_component::SvgComponent;
use regex::Regex;
use std::f32;

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

    pub fn find_nearest_neighbor(
        &self,
        target_element: &SvgElementEnum,
        alpha: f32,
    ) -> Option<(SvgElementEnum, f32)> {
        let mut best_match = None;
        let mut min_score = f32::MAX;

        self.search_node(
            &self.root,
            target_element,
            alpha,
            &mut best_match,
            &mut min_score,
        );

        best_match.map(|buddy| (buddy, min_score))
    }

    fn search_node(
        &self,
        node: &BspNode,
        target_element: &SvgElementEnum,
        alpha: f32,
        best_match: &mut Option<SvgElementEnum>,
        min_score: &mut f32,
    ) {
        for element in &node.elements {
            if element.id().unwrap_or_default() == target_element.id().unwrap_or_default() {
                continue; // Skip self
            }
            let score = calculate_closeness_score(target_element, element, alpha);
            if score < *min_score {
                *min_score = score;
                *best_match = Some(element.clone());
            }
        }

        if let Some((ref split_axis, split_point)) = node.split {
            let target_bbox = target_element.bounding_box();
            let (first_child, second_child) = match split_axis {
                BspSplitAxis::X => {
                    if target_bbox.x + target_bbox.width / 2.0 < split_point {
                        (&node.left_child, &node.right_child)
                    } else {
                        (&node.right_child, &node.left_child)
                    }
                }
                BspSplitAxis::Y => {
                    if target_bbox.y + target_bbox.height / 2.0 < split_point {
                        (&node.left_child, &node.right_child)
                    } else {
                        (&node.right_child, &node.left_child)
                    }
                }
            };

            if let Some(child) = first_child {
                self.search_node(child, target_element, alpha, best_match, min_score);
            }

            if let Some(child) = second_child {
                // Pruning: only search the other side if it could contain a closer element
                let distance_to_child_bbox = match split_axis {
                    BspSplitAxis::X => (target_bbox.x - child.bbox.x - child.bbox.width).abs(),
                    BspSplitAxis::Y => (target_bbox.y - child.bbox.y - child.bbox.height).abs(),
                };
                if distance_to_child_bbox < *min_score {
                    self.search_node(child, target_element, alpha, best_match, min_score);
                }
            }
        }
    }
}

fn get_numeric_id(name: &str) -> Option<u32> {
    let re = Regex::new(r"\d+").unwrap();
    if let Some(mat) = re.find(name) {
        mat.as_str().parse().ok()
    } else {
        None
    }
}

fn calculate_closeness_score(
    element1: &SvgElementEnum,
    element2: &SvgElementEnum,
    alpha: f32,
) -> f32 {
    let bbox1 = element1.bounding_box();
    let bbox2 = element2.bounding_box();

    let center1 = (bbox1.x + bbox1.width / 2.0, bbox1.y + bbox1.height / 2.0);
    let center2 = (bbox2.x + bbox2.width / 2.0, bbox2.y + bbox2.height / 2.0);

    let dx = center1.0 - center2.0;
    let dy = center1.1 - center2.1;
    let geometric_distance = (dx * dx + dy * dy).sqrt();

    let id1 = get_numeric_id(element1.id().unwrap_or("")).unwrap_or(0);
    let id2 = get_numeric_id(element2.id().unwrap_or("")).unwrap_or(0);
    let id_difference = (id1 as i32 - id2 as i32).abs() as f32;

    geometric_distance + (alpha * id_difference)
}
