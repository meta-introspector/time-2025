use clap::{Parser, Subcommand};
use serde::{Deserialize, Serialize};
use std::fs::{self, OpenOptions};
use std::io::{self, Write, Read};
use std::path::{Path, PathBuf};
use anyhow::{Result, Context};
use chrono::Local;
use std::collections::HashMap;

use log_analyzer::extract_urls;
use reqwest;

const CONFIG_FILE: &str = "telemetry_streams.json";
const TELEMETRY_LOG_FILE: &str = "logs/telemetry.log";

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Register a new telemetry log stream
    Register {
        /// The path to the telemetry log stream
        path: String,
    },
    /// List all registered telemetry log streams
    List,
    /// Remove a registered telemetry log stream
    Remove {
        /// The path to the telemetry log stream to remove
        path: String,
    },
    /// Log a Gemini activity
    LogGeminiCall {
        /// The message to log
        message: String,
    },
    /// Extract URLs from a given file source or all registered local file sources
    ExtractUrls {
        /// The file path to extract URLs from (optional if --registered-files is used)
        file_path: Option<String>,
        /// Extract URLs from all registered local file sources
        #[arg(long)]
        registered_files: bool,
        /// Output URLs in a pipe-friendly format (one URL per line)
        #[arg(long)]
        pipe: bool,
        /// Output a histogram of URL frequencies
        #[arg(long)]
        histogram: bool,
        /// Output the top N most frequent URLs (requires --histogram)
        #[arg(long)]
        top: Option<usize>,
    },
    /// Expand a GitHub topic URL by registering its repositories as sources
    ExpandGithubTopic {
        /// One or more GitHub topic URLs
        topic_urls: Vec<String>,
    },
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq, Eq, Hash)]
enum Source {
    File(PathBuf),
    Url(String),
}

impl std::fmt::Display for Source {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Source::File(path) => write!(f, "File: {}", path.display()),
            Source::Url(url) => write!(f, "Url: {}", url),
        }
    }
}

#[derive(Debug, Serialize, Deserialize, Default)]
struct Config {
    sources: Vec<Source>,
}

impl Config {
    fn load() -> Result<Self> {
        let config_path = PathBuf::from(CONFIG_FILE);
        if !config_path.exists() {
            return Ok(Config::default());
        }
        let config_str = fs::read_to_string(&config_path)
            .context(format!("Failed to read config file: {:?}", config_path))?;
        let config: Config = serde_json::from_str(&config_str)
            .context("Failed to deserialize config file")?;
        Ok(config)
    }

    fn save(&self) -> Result<()> {
        let config_path = PathBuf::from(CONFIG_FILE);
        let config_str = serde_json::to_string_pretty(self)
            .context("Failed to serialize config")?;
        fs::write(&config_path, config_str)
            .context(format!("Failed to write config file: {:?}", config_path))?;
        Ok(())
    }

    fn add_source(&mut self, source: Source) -> bool {
        if !self.sources.contains(&source) {
            self.sources.push(source);
            true
        } else {
            false
        }
    }

    fn remove_source(&mut self, source: &Source) -> bool {
        let initial_len = self.sources.len();
        self.sources.retain(|s| s != source);
        self.sources.len() < initial_len
    }
}

fn log_gemini_activity(message: &str) -> Result<()> {
    let log_path = PathBuf::from(TELEMETRY_LOG_FILE);
    let parent_dir = log_path.parent().context("Log file has no parent directory")?;
    fs::create_dir_all(parent_dir)
        .context(format!("Failed to create log directory: {:?}", parent_dir))?;

    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log_path)
        .context(format!("Failed to open telemetry log file: {:?}", log_path))?;

    let timestamp = Local::now().format("%Y-%m-%d %H:%M:%S").to_string();
    writeln!(file, "[{}] Gemini: {}", timestamp, message)
        .context("Failed to write to telemetry log file")?;
    Ok(())
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    let mut config = Config::load()?;

    match &cli.command {
        Commands::Register { path } => {
            let source = if path.starts_with("http://") || path.starts_with("https://") {
                Source::Url(path.clone())
            } else {
                Source::File(PathBuf::from(path))
            };
            if config.add_source(source.clone()) {
                config.save()?;
                println!("Registered telemetry source: {}", source);
            } else {
                println!("Telemetry source already registered: {}", source);
            }
        }
        Commands::List => {
            if config.sources.is_empty() {
                println!("No telemetry sources registered.");
            }
            else {
                println!("Registered telemetry sources:");
                for source in &config.sources {
                    println!("  {}", source);
                }
            }
        }
        Commands::Remove { path } => {
            let source = if path.starts_with("http://") || path.starts_with("https://") {
                Source::Url(path.clone())
            } else {
                Source::File(PathBuf::from(path))
            };
            if config.remove_source(&source) {
                config.save()?;
                println!("Removed telemetry source: {}", source);
            }
            else {
                println!("Telemetry source not found: {}", source);
            }
        }
        Commands::LogGeminiCall { message } => {
            log_gemini_activity(message)?;
            println!("Logged Gemini activity to telemetry.log");
        }
        Commands::ExtractUrls { file_path, registered_files, pipe, histogram, top } => {
            let mut all_urls: Vec<String> = Vec::new();

            if *registered_files {
                if file_path.is_some() {
                    eprintln!("Error: Cannot use --registered-files with a specific file_path.");
                    return Ok(());
                }
                println!("Extracting URLs from all registered local file sources...");
                for source in config.sources.iter() {
                    if let Source::File(path) = source {
                        let content = fs::read_to_string(path.clone())
                            .context(format!("Failed to read file: {}", path.display()))?;
                        all_urls.extend(extract_urls(&content));
                    }
                }
            } else if let Some(path) = file_path {
                let content = fs::read_to_string(path.clone())
                    .context(format!("Failed to read file: {}", path))?;
                all_urls.extend(extract_urls(&content));
            } else {
                eprintln!("Error: Either provide a file_path or use --registered-files.");
                return Ok(());
            }

            if *pipe {
                for url in all_urls {
                    println!("{}", url);
                }
            } else if *histogram || top.is_some() {
                let mut url_counts: HashMap<String, usize> = HashMap::new();
                for url in all_urls {
                    *url_counts.entry(url).or_insert(0) += 1;
                }

                let mut sorted_urls: Vec<(&String, &usize)> = url_counts.iter().collect();
                sorted_urls.sort_by(|a, b| b.1.cmp(a.1));

                let limit = top.unwrap_or(sorted_urls.len());
                println!("URL Histogram (Top {}):
----------------------------------", limit);
                for (url, count) in sorted_urls.iter().take(limit) {
                    println!("{}: {}", url, count);
                }
            } else {
                if all_urls.is_empty() {
                    println!("No URLs found.");
                } else {
                    println!("URLs found:");
                    for url in all_urls {
                        println!("  {}", url);
                    }
                }
            }
        }
        Commands::ExpandGithubTopic { topic_urls } => {
            for topic_url in topic_urls {
                println!("Expanding GitHub topic: {}", topic_url);
                let content = reqwest::blocking::get(topic_url.clone())
                    .context(format!("Failed to fetch URL: {}", topic_url))?
                    .text()
                    .context(format!("Failed to read response text from URL: {}", topic_url))?;

                let extracted_urls = extract_urls(&content);

                for repo_url in extracted_urls {
                    let source = Source::Url(repo_url.clone());
                    if config.add_source(source.clone()) {
                        println!("  Registered repository: {}", source);
                    } else {
                        println!("  Repository already registered: {}", source);
                    }
                }
                config.save()?;
            }
        }
    }

    Ok(())
}