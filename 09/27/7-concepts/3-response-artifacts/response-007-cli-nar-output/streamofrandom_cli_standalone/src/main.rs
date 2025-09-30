use clap::{Parser, Subcommand};
use std::process::{Command, Stdio};
use std::env;
use chrono::Local;
use std::fs;
use std::path::{Path, PathBuf};
use etherparse::{Ethernet2Header, IpHeader, Ipv4Header, TcpHeader, PacketBuilder};
use std::net::Ipv4Addr;
use serde::{Deserialize, Serialize};
use tempfile::tempdir;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Enters the Nix development shell for pick-up-nix2
    Dev1 {
        /// Additional flake paths to load
        #[arg(raw = true)]
        flakes: Vec<String>,
    },
    /// Enters the Nix development shell for gemini-cli
    Dev2 {
        /// Additional flake paths to load
        #[arg(raw = true)]
        flakes: Vec<String>,
    },
    /// Runs the interactive task with gemini.js
    RunTask {
        /// Arguments to pass to gemini.js
        #[arg(raw = true)]
        args: Vec<String>,
    },
    /// Manages today's directory and symlinks
    Today,
    /// Crafts TCP/IP packets based on prime numbers
    PacketCraft,
    /// Searches GitHub repositories
    GithubSearch {
        /// The search query
        query: String,
    },
    /// Processes NAR paths (placeholder)
    NarProcess {
        /// The NAR path to process
        nar_path: String,
    },
}

#[derive(Deserialize, Debug, Serialize)]
struct GithubSearchResponse {
    total_count: u32,
    incomplete_results: bool,
    items: Vec<GithubRepo>,
}

#[derive(Deserialize, Debug, Serialize)]
struct GithubRepo {
    id: u64,
    name: String,
    full_name: String,
    description: Option<String>,
    html_url: String,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Dev1 { flakes } => {
            println!("Entering Nix development shell for pick-up-nix2 and gemini-cli...");
            let nix_home = env::var("HOME")?;
            let default_flake_dev1 = PathBuf::from(nix_home.clone()).join("pick-up-nix2");
            let default_flake_gemini_cli = PathBuf::from(nix_home).join("nix").join("vendor").join("external").join("gemini-cli");
            
            let mut nix_args = vec!["develop", default_flake_dev1.to_str().unwrap(), default_flake_gemini_cli.to_str().unwrap()];
            for flake in flakes {
                nix_args.push(flake.as_str());
            }
            execute_command("nix", &nix_args)?;
        },
        Commands::Dev2 { flakes } => {
            println!("Entering Nix development shell for gemini-cli...");
            let nix_home = env::var("HOME")?;
            let default_flake = PathBuf::from(nix_home).join("nix").join("vendor").join("external").join("gemini-cli");
            
            let mut nix_args = vec!["develop", default_flake.to_str().unwrap()];
            for flake in flakes {
                nix_args.push(flake.as_str());
            }
            execute_command("nix", &nix_args)?;
        },
        Commands::RunTask { args } => {
            println!("Running interactive task with gemini.js...");
            let nix_home = env::var("HOME")?;
            let logs_dir = PathBuf::from(env::current_current_dir()?).join("logs");
            fs::create_dir_all(&logs_dir)?;

            let gemini_js_path = PathBuf::from(nix_home).join("gemini-cli").join("bundle").join("gemini.js");
            
            let mut command_args = vec![
                gemini_js_path.to_str().unwrap(),
                "--output-format", "json",
                "--approval-mode", "yolo",
                "--model", "gemini-2.5-flash",
                "--checkpointing",
                "--prompt-interactive",
            ];
            command_args.extend(args.iter().map(|s| s.as_str()));

            execute_command("node", &command_args)?;
        },
        Commands::Today => {
            println!("Managing today's directory and symlinks...");
            let nix_home = env::var("HOME")?;
            let nix_dir = PathBuf::from(nix_home.clone()).join("nix");
            fs::create_dir_all(&nix_dir)?;

            let now = Local::now();
            let current_year_month_day = now.format("%Y/%m/%d").to_string();
            let current_year_month = now.format("%Y/%m").to_string();

            let streamofrandom_base = PathBuf::from(nix_home)
                .join("source")
                .join("github")
                .join("meta-introspector")
                .join("streamofrandom");

            let today_full_path = streamofrandom_base.join(&current_year_month_day);
            let current_month_full_path = streamofrandom_base.join(&current_year_month);

            fs::create_dir_all(&today_full_path)?;

            let nix_current_month_symlink = nix_dir.join("current-month");
            if nix_current_month_symlink.exists() || nix_current_month_symlink.is_symlink() {
                fs::remove_file(&nix_current_month_symlink)?;
            }
            std::os::unix::fs::symlink(&current_month_full_path, &nix_current_month_symlink)?;

            let nix_today_symlink = nix_dir.join("today");
            if nix_today_symlink.exists() || nix_today_symlink.is_symlink() {
                fs::remove_file(&nix_today_symlink)?;
            }
            std::os::unix::fs::symlink(&today_full_path, &nix_today_symlink)?;

            env::set_current_dir(&today_full_path)?;
            println!("{}", today_full_path.display());
        },
        Commands::PacketCraft => {
            println!("Crafting TCP/IP packets based on prime numbers...");
            let zos_primes = vec![2, 3, 5, 7, 11, 13, 17, 19, 23];

            for &prime in &zos_primes {
                println!("--- Crafting packet for prime: {} ---", prime);

                // Ethernet header (dummy values for now, as it's often handled by OS)
                let eth_header = Ethernet2Header {
                    source: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00], // Dummy MAC
                    destination: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00], // Dummy MAC
                    ether_type: etherparse::EtherType::Ipv4,
                };

                // IPv4 header
                let ip_header = Ipv4Header::new(
                    20, // payload_len (will be updated by PacketBuilder)
                    64, // ttl
                    etherparse::IpTrafficClass::Tcp,
                    Ipv4Addr::new(127, 0, 0, 1), // source
                    Ipv4Addr::new(127, 0, 0, 1), // destination
                );

                // TCP header
                let tcp_header = TcpHeader::new(
                    1024, // source_port
                    prime as u16, // destination_port (using the prime)
                    0, // sequence_number
                    0, // acknowledgment_number
                    65535, // window_size
                ).syn().ack(); // SYN-ACK flags for example

                // Payload
                let payload_str = format!("Hello from prime {}!", prime);
                let payload = payload_str.as_bytes();

                // Build the packet
                let builder = PacketBuilder::new()
                    .ethernet2(eth_header.source, eth_header.destination, eth_header.ether_type)
                    .ipv4(ip_header.ttl, ip_header.traffic_class, ip_header.source, ip_header.destination)
                    .tcp(tcp_header.source_port, tcp_header.destination_port, tcp_header.sequence_number, tcp_header.acknowledgment_number)
                    .tcp_flags(tcp_header.syn, tcp_header.ack, tcp_header.fin, tcp_header.rst, tcp_header.psh, tcp_header.urg, tcp_header.ece, tcp_header.cwr, tcp_header.ns);

                // Allocate a buffer
                let mut buffer = Vec::<u8>::with_capacity(builder.size(payload.len()));
                builder.write(&mut buffer, payload)?;

                // Print as hex
                print!("Packet (hex): ");
                for byte in &buffer {
                    print!("{:02x}", byte);
                }
                println!();
            }
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
        Commands::NarProcess { nar_path } => {
            println!("Processing NAR path: {}", nar_path);
            // Placeholder for NAR processing logic
            // This would involve extracting the NAR, analyzing its content, etc.
            println!("NAR processing for {} completed (placeholder).", nar_path);
        },
    }

    Ok(())
}

fn execute_command(command_name: &str, args: &[&str]) -> Result<(), Box<dyn std::error::Error>> {
    let mut command = Command::new(command_name);
    command.args(args);
    command.stdout(Stdio::inherit());
    command.stderr(Stdio::inherit());

    let status = command.status()?;

    if !status.success() {
        return Err(format!("Command '{}' failed with status: {:?}", command_name, status).into());
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