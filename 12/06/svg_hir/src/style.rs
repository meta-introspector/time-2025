use crate::color::Color;

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Style {
    pub fill: Option<Color>,
    pub stroke: Option<Color>,
    pub stroke_width: Option<f32>,
}
