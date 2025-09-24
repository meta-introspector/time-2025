use reqwest::blocking::Client;
use scraper::{Html, Selector};
use url::Url;
use serde::{Serialize, Deserialize};
use serde_json;
use std::io::{self, BufRead, Write};
use std::time::Duration;

#[derive(Serialize, Deserialize, Debug)]
struct KnowledgeItem {
    url: String,
    tld: String,
    content: String,
    length: usize,
}

fn fetch_and_parse(client: &Client, url: &str) -> Option<String> {
    eprintln!("Fetching {}", url);
    match client.get(url).timeout(Duration::new(10, 0)).send() {
        Ok(response) => {
            if !response.status().is_success() {
                eprintln!("Error fetching {}: HTTP status {}", url, response.status());
                return None;
            }
            match response.text() {
                Ok(html_content) => {
                    let document = Html::parse_document(&html_content);
                    let main_selector = Selector::parse("main, article, body").unwrap();

                    let text = if let Some(main_content) = document.select(&main_selector).next() {
                        main_content.text().collect::<Vec<_>>().join(" ")
                    } else {
                        document.text().collect::<Vec<_>>().join(" ")
                    };

                    // Basic cleaning: normalize whitespace
                    Some(text.split_whitespace().collect::<Vec<_>>().join(" "))
                }
                Err(e) => {
                    eprintln!("Error reading response text from {}: {}", url, e);
                    None
                }
            }
        }
        Err(e) => {
            eprintln!("Error sending request to {}: {}", url, e);
            None
        }
    }
}

fn get_tld(url_str: &str) -> String {
    match Url::parse(url_str) {
        Ok(url) => {
            if let Some(domain) = url.domain() {
                let parts: Vec<&str> = domain.split('.').collect();
                if parts.len() > 1 {
                    return format!("{}.{}", parts[parts.len() - 2], parts[parts.len() - 1]);
                }
            }
            "unknown".to_string()
        }
        Err(_) => "unknown".to_string(),
    }
}

fn optimize_for_llm(text: Option<String>, max_chars: usize) -> Option<String> {
    if let Some(t) = text {
        if t.len() > max_chars {
            Some(format!("{}...", &t[0..max_chars]))
        } else {
            Some(t)
        }
    } else {
        None
    }
}

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let client = Client::new();
    let max_chars = 4000; // Matches Python script's default

    let mut stdout = io::stdout().lock();

    for line in stdin.lock().lines() {
        let url = line?;
        if url.is_empty() {
            continue;
        }

        eprintln!("Processing URL: {}", url);
        let content = fetch_and_parse(&client, &url);
        let optimized_content = optimize_for_llm(content, max_chars);

        if let Some(final_content) = optimized_content {
            let tld = get_tld(&url);
            let item = KnowledgeItem {
                url: url.clone(),
                tld,
                content: final_content.clone(),
                length: final_content.len(),
            };
            writeln!(stdout, "{}", serde_json::to_string(&item)?)?;
        }
    }

    Ok(())
}
