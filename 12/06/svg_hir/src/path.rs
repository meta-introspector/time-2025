use crate::types::bounding_box::BoundingBox;
use crate::types::style::Style;
use crate::types::transform::Transform;
use crate::types::triple::Triple;
use crate::types::monster_element_kind::MonsterElementKind;
use crate::traits::svg_component::SvgComponent;
use crate::traits::maps_to_monster::MapsToMonster;

#[derive(Debug, Clone, PartialEq)]
pub struct Path {
    pub id: Option<String>,
    pub d: String,
    pub style: Option<Style>,
    pub transform: Option<Transform>,
    pub triples: Vec<Triple>,
    pub approx_bbox: BoundingBox, // This is a placeholder. Accurate path bounding box calculation is complex.
}

impl SvgComponent for Path {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        self.approx_bbox.clone()
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
        if self.id.as_deref() == Some("path382") { // ID of the spiral path
            MonsterElementKind::P29_1
        } else {
            MonsterElementKind::P41_1
        }
    }
}
