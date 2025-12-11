use serde::{self, Serialize, Deserialize};
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct AsyncConstB {
    #[serde(rename = "cnstInfB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub cnstinfb: Option<serde_json::Value>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Arg {
    #[serde(rename = "arg")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub arg: Option<Arg>,
    #[serde(rename = "declName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub declname: Option<String>,
    #[serde(rename = "fn")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#fn: Option<Fn>,
    #[serde(rename = "levels")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub levels: Option<Vec<Level>>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Fn {
    #[serde(rename = "arg")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub arg: Option<Arg>,
    #[serde(rename = "declName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub declname: Option<String>,
    #[serde(rename = "fn")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#fn: Option<Fn>,
    #[serde(rename = "levels")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub levels: Option<Vec<Level>>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Forbd {
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "forbdB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbdb: Option<ForbdB>,
    #[serde(rename = "forbndrTyp")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbndrtyp: Option<ForbndrTyp>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct ForbdB {
    #[serde(rename = "arg")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub arg: Option<Arg>,
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "fn")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#fn: Option<Fn>,
    #[serde(rename = "forbdB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbdb: Option<ForbdB>,
    #[serde(rename = "forbndrTyp")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbndrtyp: Option<ForbndrTyp>,
    #[serde(rename = "level")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub level: Option<serde_json::Value>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct ForbndrTyp {
    #[serde(rename = "arg")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub arg: Option<Arg>,
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "declName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub declname: Option<String>,
    #[serde(rename = "fn")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#fn: Option<Fn>,
    #[serde(rename = "forbdB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbdb: Option<ForbdB>,
    #[serde(rename = "forbndrTyp")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbndrtyp: Option<ForbndrTyp>,
    #[serde(rename = "level")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub level: Option<serde_json::Value>,
    #[serde(rename = "levels")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub levels: Option<Vec<Level>>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct ForbndrTypB {
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "forbdB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbdb: Option<ForbdB>,
    #[serde(rename = "forbndrTyp")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbndrtyp: Option<ForbndrTyp>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Lambd {
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "lambdB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub lambdb: Option<LambdB>,
    #[serde(rename = "lambndrTp")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub lambndrtp: Option<LambndrTp>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct LambdB {
    #[serde(rename = "arg")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub arg: Option<Arg>,
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "fn")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#fn: Option<Fn>,
    #[serde(rename = "lambdB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub lambdb: Option<LambdB>,
    #[serde(rename = "lambndrTp")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub lambndrtp: Option<LambndrTp>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct LambndrTp {
    #[serde(rename = "arg")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub arg: Option<Arg>,
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "declName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub declname: Option<String>,
    #[serde(rename = "fn")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#fn: Option<Fn>,
    #[serde(rename = "forbdB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbdb: Option<ForbdB>,
    #[serde(rename = "forbndrTyp")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbndrtyp: Option<ForbndrTyp>,
    #[serde(rename = "level")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub level: Option<serde_json::Value>,
    #[serde(rename = "levels")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub levels: Option<Vec<Level>>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct LambndrTpB {
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "forbdB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbdb: Option<ForbdB>,
    #[serde(rename = "forbndrTyp")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbndrtyp: Option<ForbndrTyp>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Rhs {
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "lambd")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub lambd: Option<Lambd>,
    #[serde(rename = "lambndrTpB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub lambndrtpb: Option<LambndrTpB>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Type {
    #[serde(rename = "binderInfo")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub binderinfo: Option<String>,
    #[serde(rename = "binderName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bindername: Option<String>,
    #[serde(rename = "forbd")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbd: Option<Forbd>,
    #[serde(rename = "forbndrTypB")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub forbndrtypb: Option<ForbndrTypB>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct ConstantKind {
    #[serde(rename = "value")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub value: Option<String>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct ConstantVal {
    #[serde(rename = "levelParams")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub levelparams: Option<Vec<Level>>,
    #[serde(rename = "name")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(rename = "type")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Level {
    #[serde(rename = "level")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub level: Option<serde_json::Value>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct RecursorRule {
    #[serde(rename = "name")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(rename = "nfields")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub nfields: Option<i64>,
    #[serde(rename = "rhs")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rhs: Option<Rhs>,
}
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct RecursorVal {
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
    pub r#type: Option<Type>,
}
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "kind")]
pub enum Expr {
    #[serde(rename = "Lean.ConstantKind")]
    ConstantKind(ConstantKind),
    #[serde(rename = "Lean.ConstantVal")]
    ConstantVal(ConstantVal),
    #[serde(rename = "Lean.Level")]
    Level(Level),
    #[serde(rename = "Lean.RecursorRule")]
    RecursorRule(RecursorRule),
    #[serde(rename = "Lean.RecursorVal")]
    RecursorVal(RecursorVal),
}
pub type Level = serde_json::Value;
