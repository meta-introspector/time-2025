use regex::Regex;

pub fn extract_urls(text: &str) -> Vec<String> {
    let url_regex = Regex::new(r"https?://[a-zA-Z0-9\.-]+(?:/[^\s]*)?").unwrap();
    let mut urls = Vec::new();
    for cap in url_regex.captures_iter(text) {
        urls.push(cap.get(0).unwrap().as_str().to_string());
    }
    urls
}
