use crate::types::monster_element_kind::MonsterElementKind;

pub trait MapsToMonster {
    fn map_to_monster_element(&self) -> MonsterElementKind;
}
