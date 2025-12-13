use std::fs;
use std::path::{PathBuf, Path};
use serde::{Deserialize, Serialize};
use std::process::Command;
use std::collections::HashMap;

// --- Data Structures for Reports ---

#[derive(Deserialize, Debug)]
struct BuddyReportEntry {
    element: String,
    creation_order_buddy: Option<String>,
    spatial_proximity_buddy: Option<String>,
    containment_buddies: Vec<String>,
    deep_containment_buddies: Vec<String>,
}

#[derive(Deserialize, Debug)]
struct ConnectivityReportEntry {
    element: String,
    connections: Vec<String>,
}

#[derive(Deserialize, Debug)]
struct SimilarityReportEntry {
    element_a: String,
    element_b: String,
    similarity_score: f32,
}

#[derive(Serialize, Debug)]
struct MonsterMapElement {
    id: String,
    buddies: Buddies,
}

#[derive(Serialize, Debug, Default)]
struct Buddies {
    creation_order_buddy: Option<String>,
    spatial_proximity_buddy: Option<String>,
    containment_buddies: Vec<String>,
    deep_containment_buddies: Vec<String>,
    connected_to: Vec<String>,
    similar_to: Vec<SimilarityEntry>,
}

#[derive(Serialize, Debug)]
struct SimilarityEntry {
    id: String,
    score: f32,
}


fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = pico_args::Arguments::from_env();

    let input_svg_path: PathBuf = args.value_from_os_str("--input", |s| -> Result<PathBuf, String> { Ok(PathBuf::from(s)) })?;
    let output_json_path: PathBuf = args.value_from_os_str("--output", |s| -> Result<PathBuf, String> { Ok(PathBuf::from(s)) })?;

    // Create a temporary directory for intermediate reports
    let temp_dir = tempfile::tempdir()?;
    let buddy_report_path = temp_dir.path().join("buddy_report.json");
    let connectivity_report_path = temp_dir.path().join("connectivity_report.json");
    let similarity_report_path = temp_dir.path().join("similarity_report.json");

    // --- Run bsp-buddy-finder ---
    run_tool(
        "bsp-buddy-finder",
        &input_svg_path,
        &buddy_report_path,
    )?;
    let buddy_reports: Vec<BuddyReportEntry> =
        serde_json::from_str(&fs::read_to_string(&buddy_report_path)?)?;

    // --- Run connectivity-analyzer ---
    run_tool(
        "connectivity-analyzer",
        &input_svg_path,
        &connectivity_report_path,
    )?;
    let connectivity_reports: Vec<ConnectivityReportEntry> =
        serde_json::from_str(&fs::read_to_string(&connectivity_report_path)?)?;

    // --- Run similarity-analyzer ---
    run_tool(
        "similarity-analyzer",
        &input_svg_path,
        &similarity_report_path,
    )?;
    let similarity_reports: Vec<SimilarityReportEntry> =
        serde_json::from_str(&fs::read_to_string(&similarity_report_path)?)?;

    // --- Aggregate Results ---
    let mut monster_map: HashMap<String, MonsterMapElement> = HashMap::new();

    for buddy_report in buddy_reports {
        let entry = monster_map
            .entry(buddy_report.element.clone())
            .or_insert_with(|| MonsterMapElement {
                id: buddy_report.element.clone(),
                buddies: Buddies::default(),
            });
        entry.buddies.creation_order_buddy = buddy_report.creation_order_buddy;
        entry.buddies.spatial_proximity_buddy = buddy_report.spatial_proximity_buddy;
        entry.buddies.containment_buddies = buddy_report.containment_buddies;
        entry.buddies.deep_containment_buddies = buddy_report.deep_containment_buddies;
    }

    for connectivity_report in connectivity_reports {
        let entry = monster_map
            .entry(connectivity_report.element.clone())
            .or_insert_with(|| MonsterMapElement {
                id: connectivity_report.element.clone(),
                buddies: Buddies::default(),
            });
        entry.buddies.connected_to = connectivity_report.connections;
    }

    for similarity_report in similarity_reports {
        let entry_a = monster_map
            .entry(similarity_report.element_a.clone())
            .or_insert_with(|| MonsterMapElement {
                id: similarity_report.element_a.clone(),
                buddies: Buddies::default(),
            });
        entry_a.buddies.similar_to.push(SimilarityEntry {
            id: similarity_report.element_b.clone(),
            score: similarity_report.similarity_score,
        });

        let entry_b = monster_map
            .entry(similarity_report.element_b.clone())
            .or_insert_with(|| MonsterMapElement {
                id: similarity_report.element_b.clone(),
                buddies: Buddies::default(),
            });
        entry_b.buddies.similar_to.push(SimilarityEntry {
            id: similarity_report.element_a.clone(),
            score: similarity_report.similarity_score,
        });
    }

    let final_report: Vec<MonsterMapElement> = monster_map.into_values().collect();

    // --- Output Final Report ---
    let json_content = serde_json::to_string_pretty(&final_report)?;
    
    if let Some(parent) = output_json_path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&output_json_path, json_content)?;

    println!("Monster Map Report written to {}", output_json_path.display());

    Ok(())
}

fn run_tool(
    package_name: &str,
    input_svg_path: &Path,
    output_json_path: &Path,
) -> Result<(), Box<dyn std::error::Error>> {
    println!("Running {}...", package_name);
    let output = Command::new("cargo")
        .arg("run")
        .arg("-p")
        .arg(package_name)
        .arg("--")
        .arg("--input")
        .arg(input_svg_path)
        .arg("--output")
        .arg(output_json_path)
        .output()?;

    if !output.status.success() {
        eprintln!("Error running {}:", package_name);
        eprintln!("Stdout: {}", String::from_utf8_lossy(&output.stdout));
        eprintln!("Stderr: {}", String::from_utf8_lossy(&output.stderr));
        return Err(format!("Failed to run {}", package_name).into());
    }

    Ok(())
}