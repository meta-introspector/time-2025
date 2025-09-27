use clap::{Parser, Subcommand};
use std::env;
use std::fs;
use std::path::Path;
use std::process::{Command, Stdio};
use tempfile::tempdir;
use serde::{Deserialize, Serialize};

#[derive(Parser)]
#[command(name = "streamofrandom_cli")]
#[command(about = "A CLI tool for various operations with NAR output")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Today,
    PacketCraft,
    GithubSearch { query: String },
}

#[derive(Serialize, Deserialize)]
struct GithubSearchResponse {
    total_count: u32,
    incomplete_results: bool,
    items: Vec<GithubRepo>,
}

#[derive(Serialize, Deserialize)]
struct GithubRepo {
    id: u64,
    name: String,
    full_name: String,
    description: Option<String>,
    html_url: String,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Today => {
            println!("Today's operations with NAR output");
            let temp_dir = tempdir()?;
            let output_file = temp_dir.path().join("today.txt");
            fs::write(&output_file, "Today's output")?;
            
            let nar_path = create_nar_from_path(temp_dir.path())?;
            println!("{}", nar_path);
        },
        Commands::PacketCraft => {
            println!("Crafting network packets with NAR output");
            let temp_dir = tempdir()?;
            let output_file = temp_dir.path().join("packet.bin");
            fs::write(&output_file, b"fake packet data")?;
            
            let nar_path = create_nar_from_path(temp_dir.path())?;
            println!("{}", nar_path);
        },
        Commands::GithubSearch { query } => {
            println!("Searching GitHub for: {}", query);
            let github_token = env::var("GITHUB_TOKEN")
                .map_err(|_| "GITHUB_TOKEN environment variable not set.")?;

            let client = reqwest::blocking::Client::new();
            let url = format!("https://api.github.com/search/repositories?q={}", query);

            let response = client.get(&url)
                .header(reqwest::header::USER_AGENT, "streamofrandom_cli")
                .header(reqwest::header::AUTHORIZATION, format!("token {}", github_token))
                .send()?;

            let search_results: GithubSearchResponse = response.json()?;

            let temp_dir = tempdir()?;
            let output_file = temp_dir.path().join("github_search_results.json");
            fs::write(&output_file, serde_json::to_string_pretty(&search_results)?)?;

            let nar_path = create_nar_from_path(temp_dir.path())?;
            println!("{}", nar_path);
        },
    }

    Ok(())
}

fn create_nar_from_path(path: &Path) -> Result<String, Box<dyn std::error::Error>> {
    let output = Command::new("nix-store")
        .arg("--dump")
        .arg(path)
        .output()?;

    if !output.status.success() {
        return Err(format!("nix-store --dump failed: {}", String::from_utf8_lossy(&output.stderr)).into());
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}