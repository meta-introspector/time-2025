use clap::{Parser, Subcommand};
use std::process::{Command, Stdio};
use std::env;
use chrono::Local;
use std::fs;
use std::path::PathBuf;

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