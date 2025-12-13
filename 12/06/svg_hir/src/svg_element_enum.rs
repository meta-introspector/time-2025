use crate::bounding_box::BoundingBox;
use crate::monster_element_kind::MonsterElementKind;
use crate::rect::Rect;
use crate::circle::Circle;
use crate::ellipse::Ellipse;
use crate::group::Group;
use crate::text::Text;
use crate::path::Path;
use crate::style::Style;
use crate::traits::svg_component::SvgComponent;
use crate::traits::maps_to_monster::MapsToMonster;

/// An enum to hold any of the possible SVG elements, allowing for heterogeneous collections.
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum SvgElementEnum {
    Rect(Rect),
    Circle(Circle),
    Ellipse(Ellipse),
    Group(Group),
    Text(Text),
    Path(Path),
}

// Blanket implementation for SvgComponent for SvgElementEnum
impl SvgComponent for SvgElementEnum {
    fn id(&self) -> Option<&str> {
        match self {
            SvgElementEnum::Rect(r) => r.id(),
            SvgElementEnum::Circle(c) => c.id(),
            SvgElementEnum::Ellipse(e) => e.id(),
            SvgElementEnum::Group(g) => g.id(),
            SvgElementEnum::Text(t) => t.id(),
            SvgElementEnum::Path(p) => p.id(),
        }
    }

    fn bounding_box(&self) -> BoundingBox {
        match self {
            SvgElementEnum::Rect(r) => r.bounding_box(),
            SvgElementEnum::Circle(c) => c.bounding_box(),
            SvgElementEnum::Ellipse(e) => e.bounding_box(),
            SvgElementEnum::Group(g) => g.bounding_box(),
            SvgElementEnum::Text(t) => t.bounding_box(),
            SvgElementEnum::Path(p) => p.bounding_box(),
        }
    }

    fn size(&self) -> f32 {
        match self {
            SvgElementEnum::Rect(r) => r.size(),
            SvgElementEnum::Circle(c) => c.size(),
            SvgElementEnum::Ellipse(e) => e.size(),
            SvgElementEnum::Group(g) => g.size(),
            SvgElementEnum::Text(t) => t.size(),
            SvgElementEnum::Path(p) => p.size(),
        }
    }

    fn style(&self) -> Option<&Style> {
        match self {
            SvgElementEnum::Rect(r) => r.style(),
            SvgElementEnum::Circle(c) => c.style(),
            SvgElementEnum::Ellipse(e) => e.style(),
            SvgElementEnum::Group(g) => g.style(),
            SvgElementEnum::Text(t) => t.style(),
            SvgElementEnum::Path(p) => p.style(),
        }
    }
}

// Blanket implementation for MapsToMonster for SvgElementEnum
impl MapsToMonster for SvgElementEnum {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        match self {
            SvgElementEnum::Rect(r) => r.map_to_monster_element(),
            SvgElementEnum::Circle(c) => c.map_to_monster_element(),
            SvgElementEnum::Ellipse(e) => e.map_to_monster_element(),
            SvgElementEnum::Group(g) => g.map_to_monster_element(),
            SvgElementEnum::Text(t) => t.map_to_monster_element(),
            SvgElementEnum::Path(p) => p.map_to_monster_element(),
        }
    }
}