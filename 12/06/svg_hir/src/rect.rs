use crate::bounding_box::BoundingBox;
use crate::style::Style;
use crate::transform::Transform;
use crate::triple::Triple;
use crate::monster_element_kind::MonsterElementKind;
use crate::traits::svg_component::SvgComponent;
use crate::traits::maps_to_monster::MapsToMonster;

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Rect {
    pub id: Option<String>,
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
    pub rx: Option<f32>,
    pub ry: Option<f32>,
    pub style: Option<Style>,
    pub transform: Option<Transform>,
    pub triples: Vec<Triple>,
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
        if self.triples.len() > 0 {
            MonsterElementKind::P3_20
        } else {
            MonsterElementKind::P31_1
        }
    }
}
