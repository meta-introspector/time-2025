use crate::bounding_box::BoundingBox;
use crate::style::Style;
use crate::transform::Transform;
use crate::triple::Triple;
use crate::monster_element_kind::MonsterElementKind;
use crate::traits::svg_component::SvgComponent;
use crate::traits::maps_to_monster::MapsToMonster;
use usvg::parser::EId;

#[derive(Debug, Clone, PartialEq, Default, serde::Serialize, serde::Deserialize)]
pub struct Ellipse {
    pub id: Option<String>,
    pub cx: f32,
    pub cy: f32,
    pub rx: f32,
    pub ry: f32,
    pub style: Option<Style>,
    pub transform: Option<Transform>,
    pub triples: Vec<Triple>,
    #[serde(skip)]
    pub original_eid: Option<EId>,
}

impl SvgComponent for Ellipse {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        BoundingBox::new(self.cx - self.rx, self.cy - self.ry, self.rx * 2.0, self.ry * 2.0)
    }

    fn size(&self) -> f32 {
        std::f32::consts::PI * self.rx * self.ry
    }

    fn style(&self) -> Option<&Style> {
        self.style.as_ref()
    }
}

impl MapsToMonster for Ellipse {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        if self.triples.len() > 0 {
            MonsterElementKind::P3_20
        } else {
            MonsterElementKind::P47_1
        }
    }
}
