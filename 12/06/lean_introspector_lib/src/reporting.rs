pub fn format_split_ref(key: &str) -> String {
    format!("./{}/_report.json", key)
}

pub fn format_split_value_path(path_str: &str, value_json: &serde_json::Value) -> String {
    format!("  Path: \"{}\" -> Value: {}", path_str, serde_json::to_string_pretty(value_json).unwrap_or_else(|_| "[Error converting value]".to_string()))
}

pub fn format_split_not_found_path(path_str: &str) -> String {
    format!("  Path: \"{}\" -> Value: [Not Found or Invalid Path]", path_str)
}

pub fn format_ontology_triple(s: &str, p: &str, o: &str) -> String {
    format!("  (\"{}\", \"{}\", \"{}\")", s, p, o)
}

pub fn format_collection_type(element_type: &str) -> String {
    format!("owl:Collection<{}>", element_type)
}

pub fn format_object_property_type(subject_base: &str, prop_name: &str) -> String {
    format!("{}.{}", subject_base, prop_name)
}