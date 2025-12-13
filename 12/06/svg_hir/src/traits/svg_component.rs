use crate::bounding_box::BoundingBox;
use crate::style::Style;

pub trait SvgComponent {
    fn id(&self) -> Option<&str>;
    fn bounding_box(&self) -> BoundingBox;
    fn size(&self) -> f32;
    fn style(&self) -> Option<&Style>;
}