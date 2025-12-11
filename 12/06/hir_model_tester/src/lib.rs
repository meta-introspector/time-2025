use serde::{self, Serialize, Deserialize};
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct AsyncConstB {
    #[serde(rename = "cnstInfB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub cnstinfb: Option<serde_json::Value>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct LeanConstantKind {
    #[serde(rename = "value")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub value: Option<String>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct LeanConstantVal {
    #[serde(rename = "levelParams")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub levelparams: Option<Vec<Level>>,
    #[serde(rename = "name")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<String>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct LeanLevel {
    #[serde(rename = "level")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub level: Option<serde_json::Value>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct LeanRecursorRule {
    #[serde(rename = "name")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(rename = "nfields")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub nfields: Option<i64>,
    #[serde(rename = "rhs")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rhs: Option<Box<Expr>>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct LeanRecursorVal {
    #[serde(rename = "Rules")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rules: Option<Vec<Expr>>,
    #[serde(rename = "all")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub all: Option<Vec<Level>>,
    #[serde(rename = "isUnsafe")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub isunsafe: Option<bool>,
    #[serde(rename = "k")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub k: Option<bool>,
    #[serde(rename = "levelParams")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub levelparams: Option<Vec<Level>>,
    #[serde(rename = "name")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(rename = "numIndices")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub numindices: Option<i64>,
    #[serde(rename = "numMinors")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub numminors: Option<i64>,
    #[serde(rename = "numMotives")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub nummotives: Option<i64>,
    #[serde(rename = "numParams")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub numparams: Option<i64>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<String>,
}
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "kind")]
pub enum Expr {
    #[serde(rename = "AsyncConstB")]
    AsyncConstB(AsyncConstB),
    #[serde(rename = "Lean.ConstantKind")]
    LeanConstantKind(LeanConstantKind),
    #[serde(rename = "Lean.ConstantVal")]
    LeanConstantVal(LeanConstantVal),
    #[serde(rename = "Lean.Level")]
    LeanLevel(LeanLevel),
    #[serde(rename = "Lean.RecursorRule")]
    LeanRecursorRule(LeanRecursorRule),
    #[serde(rename = "Lean.RecursorVal")]
    LeanRecursorVal(LeanRecursorVal),
}
pub type Level = serde_json::Value;
