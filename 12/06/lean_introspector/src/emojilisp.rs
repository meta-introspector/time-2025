use std::collections::HashMap;
use serde_json::Value;
use lazy_static::lazy_static; // Import lazy_static macro

lazy_static! {
    /// A static HashMap to store the Emoji-Lisp primitive mappings.
    static ref EMOJI_MAP: HashMap<&'static str, &'static str> = {
        let mut m = HashMap::new();
        // Conceptual operations
        m.insert("fn", "📜✍️");
        m.insert("eval", "▶️🧠");
        m.insert("apply", "✨➡️");
        m.insert("bind", "🔗🏷️");
        m.insert("let", "🎁📦");
        m.insert("form", "🧩📝");
        m.insert("const", "💎🔒");
        m.insert("literal", "🔢💡");
        m.insert("cons", "➕🔗");
        m.insert("cadr", "➡️🥈");
        m.insert("car", "➡️🥇");
        // Data representation (SimpleExpr specific)
        m.insert("object", "📦");
        m.insert("key_value", "🏷️➡️");
        m.insert("string_value", "📝");
        m.insert("number_value", "🔢");
        m
    };
}

// Function to convert serde_json::Value to an Emoji-Lisp string
pub fn json_to_emoji_lisp_string(json_value: &Value) -> String {
    let mut emoji_lisp_parts = Vec::new();

    match json_value {
        Value::Object(map) => {
            emoji_lisp_parts.push(EMOJI_MAP["form"].to_string()); // The entire JSON is a form
            
            for (key, val) in map {
                emoji_lisp_parts.push(EMOJI_MAP["key_value"].to_string()); // Start of a key-value pair
                emoji_lisp_parts.push(EMOJI_MAP["string_value"].to_string()); // Key is a string
                emoji_lisp_parts.push(format!("\"{}\"", key)); // Actual key name

                // Value is treated as a literal constant
                emoji_lisp_parts.push(EMOJI_MAP["const"].to_string());
                emoji_lisp_parts.push(EMOJI_MAP["literal"].to_string());

                match val {
                    Value::String(s) => {
                        emoji_lisp_parts.push(EMOJI_MAP["string_value"].to_string());
                        emoji_lisp_parts.push(format!("\"{}\"", s));
                    },
                    Value::Number(n) => {
                        emoji_lisp_parts.push(EMOJI_MAP["number_value"].to_string());
                        emoji_lisp_parts.push(n.to_string());
                    },
                    _ => {
                        // For simplicity, handle only string and number values for SimpleExpr
                        emoji_lisp_parts.push(EMOJI_MAP["string_value"].to_string());
                        emoji_lisp_parts.push("\"UNSUPPORTED_TYPE\"".to_string());
                    }
                }
            }
        },
        _ => {
            // For SimpleExpr, we expect an object. Handle other types as a simple literal if encountered.
            emoji_lisp_parts.push(EMOJI_MAP["literal"].to_string());
            emoji_lisp_parts.push(json_value.to_string());
        }
    }

    emoji_lisp_parts.join(" ")
}
