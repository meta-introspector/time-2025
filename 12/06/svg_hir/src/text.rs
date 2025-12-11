use crate::types::bounding_box::BoundingBox;
use crate::types::style::Style;
use crate::types::transform::Transform;
use crate::types::triple::Triple;
use crate::types::monster_element_kind::MonsterElementKind;
use crate::traits::svg_component::SvgComponent;
use crate::traits::maps_to_monster::MapsToMonster;

#[derive(Debug, Clone, PartialEq)]
pub struct Text {
    pub id: Option<String>,
    pub x: f32,
    pub y: f32,
    pub content: String,
    pub word_count: usize,
    pub style: Option<Style>,
    pub transform: Option<Transform>,
    pub triples: Vec<Triple>,
}

impl SvgComponent for Text {
    fn id(&self) -> Option<&str> {
        self.id.as_deref()
    }

    fn bounding_box(&self) -> BoundingBox {
        let char_width_approx = 5.0;
        let char_height_approx = 10.0;
        let width = self.content.len() as f32 * char_width_approx;
        let height = char_height_approx;
        BoundingBox::new(self.x, self.y - height, width, height)
    }

    fn size(&self) -> f32 {
        self.bounding_box().area()
    }
}

impl MapsToMonster for Text {
    fn map_to_monster_element(&self) -> MonsterElementKind {
        if self.triples.len() > 0 {
            return MonsterElementKind::P3_20;
        }

        match self.content.as_str() {
            "0" => MonsterElementKind::P2_46,
            "1" => MonsterElementKind::P3_20,
            "2" => MonsterElementKind::P5_9,
            "3" => MonsterElementKind::P7_6,
            "5" => MonsterElementKind::P11_2,
            "7" => MonsterElementKind::P13_3,
            "11" => MonsterElementKind::P17_1,
            "17" => MonsterElementKind::P19_1,
            "19" => MonsterElementKind::P23_1,
            "23" => MonsterElementKind::P29_1,
            "71" => MonsterElementKind::P71_1,
            "aws" | "github" | "ssm" | "gcc" | "qemu" | "docker" | "k8s" | "systemd" => MonsterElementKind::ExternalSystem,
            _ => {
                match self.word_count {
                    1 => MonsterElementKind::TextOnePart,
                    2 => MonsterElementKind::TextTwoParts,
                    3 => MonsterElementKind::TextThreeParts,
                    _ => MonsterElementKind::Unknown,
                }
            }
        }
    }
}
