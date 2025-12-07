use crate::types::bounding_box::BoundingBox;
use crate::types::style::Style;
use crate::types::transform::Transform;
use crate::types::triple::Triple;
use crate::types::svg_element_enum::SvgElementEnum;
use crate::types::monster_element_kind::MonsterElementKind;
use crate::traits::svg_component::SvgComponent;
use crate::traits::maps_to_monster::MapsToMonster;

#[derive(Debug, Clone, PartialEq)]
pub struct Group {
    pub id: Option<String>,
    pub children: Vec<SvgElementEnum>,
    pub transform: Option<Transform>,
    pub style: Option<Style>,
    pub triples: Vec<Triple>,
}

impl SvgComponent for Group {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        let mut min_x = f32::MAX;
        let mut min_y = f32::MAX;
        let mut max_x = f32::MIN;
        let mut max_y = f32::MIN;

        if self.children.is_empty() {
            return BoundingBox::new(0.0, 0.0, 0.0, 0.0);
        }

        for child in &self.children {
            let child_bbox = child.bounding_box();
            min_x = min_x.min(child_bbox.x);
            min_y = min_y.min(child_bbox.y);
            max_x = max_x.max(child_bbox.x + child_bbox.width);
            max_y = max_y.max(child_bbox.y + child_bbox.height);
        }

        BoundingBox::new(min_x, min_y, max_x - min_x, max_y - min_y)
    }

    fn size(&self) -> f32 {
        self.bounding_box().area()
    }
}

impl MapsToMonster for Group {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        if self.triples.len() > 0 {
            return MonsterElementKind::P3_20;
        }

        match self.children.len() {
            9 => MonsterElementKind::P5_9,
            6 => MonsterElementKind::P7_6,
            11 => MonsterElementKind::P11_2,
            13 => MonsterElementKind::P13_3,
            _ => MonsterElementKind::P59_1,
        }
    }
}
