use std::{fs, path::PathBuf};
use clap::Parser;
use anyhow::{Result, Context};
use rnix::{Root, SyntaxElement, SyntaxKind, TextRange, WalkEvent};
use serde::{Serialize, Deserialize};
use std::collections::HashMap;

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    /// Path to a file containing a newline-separated list of flake.lock paths.
    #[clap(long)]
    lock_files: PathBuf,

    /// Path to a file containing a newline-separated list of flake.nix store paths.
    #[clap(long)]
    nix_files: PathBuf,

    /// Output path for the generated JSON audit report.
    #[clap(long)]
    output: PathBuf,
}

#[derive(Debug, Serialize, Deserialize)]
struct InvertedIndexEntry {
    file_path: String,
    start_byte: u32,
    end_byte: u32,
}

#[derive(Debug, Serialize, Deserialize)]
struct Locked {
    #[serde(rename = "type")]
    node_type: String,
    owner: Option<String>,
    repo: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
struct Node {
    locked: Option<Locked>,
}

#[derive(Debug, Serialize, Deserialize)]
struct FlakeLock {
    nodes: HashMap<String, Node>,
}

#[derive(Debug, Serialize, Deserialize)]
struct AuditReport {
    constants: HashMap<String, Vec<InvertedIndexEntry>>,
    paths: HashMap<String, Vec<InvertedIndexEntry>>,
    flake_lock_audits: HashMap<String, Vec<String>>, // Stores non-meta-introspector owners per flake.lock file
}

fn main() -> Result<()> {
    let args = Args::parse();

    let lock_file_paths = read_paths_from_file(&args.lock_files)
        .context("Failed to read lock file paths")?;
    let nix_file_paths = read_paths_from_file(&args.nix_files)
        .context("Failed to read nix file paths")?;

    let mut audit_report = AuditReport {
        constants: HashMap::new(),
        paths: HashMap::new(),
        flake_lock_audits: HashMap::new(),
    };

    // Process flake.nix files
    for nix_file_path_str in nix_file_paths {
        let nix_file_path = PathBuf::from(&nix_file_path_str);
        let content = fs::read_to_string(&nix_file_path)
            .with_context(|| format!("Failed to read Nix file: {}", nix_file_path_str))?;

        let root = Root::parse(&content);
        if !root.errors().is_empty() {
            eprintln!("Warning: Errors parsing {}: {:?}", nix_file_path_str, root.errors());
        }

        // Traverse the AST to find constants and paths
        for event in root.syntax().preorder_with_tokens() {
            if let WalkEvent::Enter(element) = event {
                match element {
                    SyntaxElement::Token(token) => {
                        match token.kind() {
                            SyntaxKind::TOKEN_STRING_CONTENT | SyntaxKind::TOKEN_URI | SyntaxKind::TOKEN_INTEGER | SyntaxKind::TOKEN_FLOAT => {
                                let text = token.text().to_string();
                                let entry = InvertedIndexEntry {
                                    file_path: nix_file_path_str.clone(),
                                    start_byte: u32::from(token.text_range().start()),
                                    end_byte: u32::from(token.text_range().end()),
                                };
                                audit_report.constants.entry(text).or_default().push(entry);
                            },
                            _ => {},
                        }
                    },
                    SyntaxElement::Node(node) => {
                        // For paths, we'll consider NODE_PATH and NODE_ATTRPATH
                        match node.kind() {
                            SyntaxKind::NODE_PATH => {
                                let text = node.text().to_string();
                                let entry = InvertedIndexEntry {
                                    file_path: nix_file_path_str.clone(),
                                    start_byte: u32::from(node.text_range().start()),
                                    end_byte: u32::from(node.text_range().end()),
                                };
                                audit_report.paths.entry(text).or_default().push(entry);
                            },
                            SyntaxKind::NODE_ATTRPATH => {
                                let text = node.text().to_string();
                                let entry = InvertedIndexEntry {
                                    file_path: nix_file_path_str.clone(),
                                    start_byte: u32::from(node.text_range().start()),
                                    end_byte: u32::from(node.text_range().end()),
                                };
                                audit_report.paths.entry(text).or_default().push(entry);
                            },
                            _ => {},
                        }
                    },
                }
            }
        }
    }

    // Process flake.lock files
    for lock_file_path_str in lock_file_paths {
        let lock_file_path = PathBuf::from(&lock_file_path_str);
        let contents = fs::read_to_string(&lock_file_path)
            .with_context(|| format!("Failed to read flake.lock file: {}", lock_file_path_str))?;
        
        let flake_lock: FlakeLock = match serde_json::from_str(&contents) {
            Ok(lock) => lock,
            Err(e) => {
                eprintln!("Error parsing {}: {}", lock_file_path_str, e);
                continue;
            }
        };

        let mut non_meta_introspector_owners = Vec::new();

        for (node_name, node) in flake_lock.nodes {
            if let Some(locked) = node.locked {
                if locked.node_type == "github" {
                    if let Some(owner) = locked.owner {
                        if owner != "meta-introspector" {
                            let repo = locked.repo.unwrap_or_else(|| "unknown".to_string());
                            non_meta_introspector_owners.push(format!("{}/{} (node: {})", owner, repo, node_name));
                        }
                    }
                }
            }
        }

        if !non_meta_introspector_owners.is_empty() {
            audit_report.flake_lock_audits.insert(lock_file_path_str, non_meta_introspector_owners);
        }
    }

    let output_content = serde_json::to_string_pretty(&audit_report)
        .context("Failed to serialize audit report to JSON")?;
    fs::write(&args.output, output_content)
        .with_context(|| format!("Failed to write output to {}", args.output.display()))?;

    println!("Audit report generated successfully at {}", args.output.display());

    Ok(())
}

fn read_paths_from_file(file_path: &PathBuf) -> Result<Vec<String>> {
    let content = fs::read_to_string(file_path)
        .with_context(|| format!("Failed to read paths from file: {}", file_path.display()))?;
    Ok(content.lines().filter(|s| !s.trim().is_empty()).map(|s| s.to_string()).collect())
}