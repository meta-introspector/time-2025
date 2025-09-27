{
  description = "Gemini's response: Implement 'github-search' subcommand in streamofrandom_cli.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # Input for the streamofrandom_cli project, which is in the parent directory
    streamofrandomCli = {
      url = "path:../"; # Refers to the parent directory where the workspace is
      flake = false; # Treat as a non-flake input
    };
  };

  outputs = { self, nixpkgs, streamofrandomCli, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux; # Or appropriate system

      # Define the modified Cargo.toml content
      modifiedCargoToml = pkgs.writeText "Cargo.toml" ''
        [package]
        name = "streamofrandom_cli"
        version = "0.1.0"
        edition = "2021"
        rust-version = "1.70"
        license = "MIT"
        authors = ["Your Name <your.email@example.com>"]
        repository = "https://github.com/meta-introspector/streamofrandom"
        homepage = "https://github.com/meta-introspector/streamofrandom"
        documentation = "https://github.com/meta-introspector/streamofrandom"
        description = "A CLI tool for streamofrandom project"
        keywords = ["cli", "nix", "automation"]
        categories = ["command-line-utilities"]

        [dependencies]
        clap = { version = "4.0", features = ["derive"] }
        chrono = "0.4"
        etherparse = "0.14"
        reqwest = { version = "0.11", features = ["json", "blocking"] }
        serde = { version = "1.0", features = ["derive"] }
        serde_json = "1.0"

        [lints]
        # Add specific lints here if needed, or remove this section if not using workspace lints
      '';

      # Define the modified src/main.rs content
      modifiedMainRs = pkgs.writeText "main.rs" ''
        use clap::{Parser, Subcommand};
        use std::process::{Command, Stdio};
        use std::env;
        use chrono::Local;
        use std::fs;
        use std::path::PathBuf;
        use etherparse::{Ethernet2Header, IpHeader, Ipv4Header, TcpHeader, PacketBuilder};
        use std::net::Ipv4Addr;
        use serde::Deserialize;

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
        }

        #[derive(Deserialize, Debug)]
        struct GithubSearchResponse {
            items: Vec<GithubRepository>,
        }

        #[derive(Deserialize, Debug)]
        struct GithubRepository {
            name: String,
            full_name: String,
            html_url: String,
            description: Option<String>,
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
                    let logs_dir = PathBuf::from(env::current_dir()?).join("logs");
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

                    if search_results.items.is_empty() {
                        println!("No repositories found for query: {}", query);
                    } else {
                        for repo in search_results.items {
                            println!("  Name: {}", repo.name);
                            println!("  Full Name: {}", repo.full_name);
                            println!("  URL: {}", repo.html_url);
                            if let Some(desc) = repo.description {
                                println!("  Description: {}", desc);
                            }
                            println!("----------------------------------------");
                        }
                    }
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
      '';

      # A derivation to apply the changes to streamofrandom_cli
      modifiedStreamofrandomCli = pkgs.runCommand "streamofrandom-cli-with-github-search"
        {
          inherit streamofrandomCli; # Pass the original source
          cargoToml = modifiedCargoToml;
          mainRs = modifiedMainRs;
        } ''
        cp -r $streamofrandomCli $out
        cp $cargoToml $out/streamofrandom_cli/Cargo.toml
        cp $mainRs $out/streamofrandom_cli/src/main.rs
      '';

      # Build the modified streamofrandom_cli
      cliPackage = pkgs.callPackage
        ({ rustPlatform, lib, openssl }:
          rustPlatform.buildRustPackage {
            pname = "streamofrandom_cli";
            version = "0.1.0";
            src = modifiedStreamofrandomCli; # Use the modified source
            cargoLock = "${streamofrandomCli}/Cargo.lock"; # Still use the original Cargo.lock
            buildInputs = [ openssl ];
            cargoRoot = modifiedStreamofrandomCli;
            sourceRoot = "streamofrandom_cli";
          }
        )
        { };

      defaultPackage = cliPackage; # The default output is the built CLI

      devShell = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.bash ];
        shellHook = ''
          echo "Welcome to the devShell for response-005-github-search."
          echo "The 'streamofrandom_cli' is available in your PATH."
          echo "Try: streamofrandom_cli github-search <query>"
          echo "Remember to set GITHUB_TOKEN environment variable."
        '';
      };
      };
