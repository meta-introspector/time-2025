pub fn escape_text(text: &str) -> String {
    text.chars()
        .map(|c| match c {
            '&' => "&amp;".to_string(),
            '<' => "&lt;".to_string(),
            '>' => "&gt;".to_string(),
            '"' => "&quot;".to_string(),
            '\'' => "&apos;".to_string(),
            ' ' => "_".to_string(),
            _ if !c.is_ascii_alphanumeric() => format!("_{:x}_", c as u32),
            _ => c.to_string(),
        })
        .collect()
}
