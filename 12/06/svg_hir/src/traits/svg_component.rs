use crate::bounding_box::BoundingBox;

pub trait SvgComponent {
    fn id(&self) -> Option<&str>;
    fn bounding_box(&self) -> BoundingBox;
    fn size(&self) -> f32;
}
