
use crate::monster_element_kind::MonsterElementKind;

pub trait WithOriginalKind {
    fn original_kind(&self) -> MonsterElementKind;
}
