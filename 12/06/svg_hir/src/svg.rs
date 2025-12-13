use crate::bounding_box::BoundingBox;
use crate::style::Style;
use crate::triple::Triple;
use crate::svg_element_enum::SvgElementEnum;
use crate::monster_element_kind::MonsterElementKind;
use crate::traits::svg_component::SvgComponent;
use crate::traits::maps_to_monster::MapsToMonster;

/// The root of the SVG structure.
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Svg {
    pub id: Option<String>,
    pub width: String,
    pub height: String,
    pub view_box: Option<String>,
    pub children: Vec<SvgElementEnum>,
    pub triples: Vec<Triple>,
}

impl SvgComponent for Svg {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        let mut min_x = f32::MAX;
        let mut min_y = f32::MAX;
        let mut max_x = f32::MIN;
        let mut max_y = f32::MIN;

        if self.children.is_empty() {
            let width = self.width.parse::<f32>().unwrap_or_default();
            let height = self.height.parse::<f32>().unwrap_or_default();
            return BoundingBox::new(0.0, 0.0, width, height);
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

    fn style(&self) -> Option<&Style> {
        None
    }
}

impl MapsToMonster for Svg {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        if self.triples.len() > 0 {
            MonsterElementKind::P3_20
        } else {
            MonsterElementKind::P71_1
        }
    }
}