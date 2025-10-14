use std::fs;
use std::path::Path;
use serde::Deserialize;
use std::collections::HashMap;
use glob::glob;

#[derive(Deserialize, Debug)]
struct Locked {
    #[serde(rename = "type")]
    node_type: String,
    owner: Option<String>,
    repo: Option<String>,
}

#[derive(Deserialize, Debug)]
struct Node {
    locked: Option<Locked>,
}

#[derive(Deserialize, Debug)]
struct FlakeLock {
    nodes: HashMap<String, Node>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let root_path = "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/";
    let pattern = format!("{}/**/flake.lock", root_path);

    for entry in glob(&pattern)? {
        let path = entry?;
        let flake_lock_path_str = path.to_string_lossy();

        println!("--------------------------------------------------");
        println!("Auditing {}:", flake_lock_path_str);

        let contents = fs::read_to_string(&path)?;
        let flake_lock: FlakeLock = match serde_json::from_str(&contents) {
            Ok(lock) => lock,
            Err(e) => {
                eprintln!("Error parsing {}: {}", flake_lock_path_str, e);
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
            println!("Found flake inputs with owners other than 'meta-introspector':");
            for entry in non_meta_introspector_owners {
                println!("- {}", entry);
            }
        } else {
            println!("All flake inputs are owned by 'meta-introspector'.");
        }
    }

    Ok(())
}