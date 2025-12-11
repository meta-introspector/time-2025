use serde_json::{json, Value};
use std::fs;
use std::io::{self, Write};
use config_lib;

fn transform_value(name: &str, value: Value) -> Value {
    match value {
        Value::Object(map) => {
            let children: Vec<Value> = map
                .into_iter()
                .map(|(key, val)| transform_value(&key, val))
                .collect();
            json!({
                "name": name,
                "json_type": "ObjectType",
                "children": children
            })
        }
        Value::Array(arr) => {
            let children: Vec<Value> = arr
                .into_iter()
                .enumerate()
                .map(|(i, val)| transform_value(&i.to_string(), val))
                .collect();
            json!({
                "name": name,
                "json_type": "ArrayType",
                "children": children
            })
        }
        Value::String(s) => json!({
            "name": name,
            "json_type": "StringType",
            "value": s
        }),
        Value::Number(n) => json!({
            "name": name,
            "json_type": "NumberType",
            "value": n
        }),
        Value::Bool(b) => json!({
            "name": name,
            "json_type": "BooleanType",
            "value": b
        }),
        Value::Null => json!({
            "name": name,
            "json_type": "NullType",
            "value": null
        }),
    }
}

fn main() -> io::Result<()> {
    let (config, _) = config_lib::find_and_read_config("lean_introspector/config.toml").map_err(|e| {
        eprintln!("Failed to read config file: {}", e);
        io::Error::new(io::ErrorKind::NotFound, e)
    })?;

    let input_path = &config.input_file;
    let content = fs::read_to_string(input_path)?;
    let parsed_json: Value = serde_json::from_str(&content)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;

    let transformed_json = transform_value("root", parsed_json);

    let stdout = io::stdout();
    let mut handle = stdout.lock();
    serde_json::to_writer_pretty(&mut handle, &transformed_json)?;
    writeln!(handle)?;

    Ok(())
}