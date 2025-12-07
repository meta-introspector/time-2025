use crate::types::color::Color;

#[derive(Debug, Clone, PartialEq)]
pub struct Style {
    pub fill: Option<Color>,
    pub stroke: Option<Color>,
    pub stroke_width: Option<f32>,
}
