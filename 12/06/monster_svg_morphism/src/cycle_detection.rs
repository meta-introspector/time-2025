use std::collections::HashMap;

// Helper function for DFS-based cycle detection
pub fn find_cycles_dfs(
    graph: &HashMap<String, Vec<String>>,
    node: &str,
    visited: &mut HashMap<String, bool>,
    recursion_stack: &mut HashMap<String, bool>,
    path: &mut Vec<String>,
    cycles: &mut Vec<(String, Vec<String>)>,
    primes_to_check: &[u64],
) {
    visited.insert(node.to_string(), true);
    recursion_stack.insert(node.to_string(), true);
    path.push(node.to_string());

    if let Some(callees) = graph.get(node) {
        for callee in callees {
            if !visited.get(callee).unwrap_or(&false) {
                find_cycles_dfs(graph, callee, visited, recursion_stack, path, cycles, primes_to_check);
            } else if *recursion_stack.get(callee).unwrap_or(&false) {
                // Cycle detected!
                let cycle_start_index = path.iter().position(|f| f == callee).unwrap();
                let cycle_path: Vec<String> = path[cycle_start_index..].to_vec();
                
                // Check if cycle length matches any of the configured primes
                if primes_to_check.contains(&(cycle_path.len() as u64)) {
                    cycles.push((node.to_string(), cycle_path));
                }
            }
        }
    }

    path.pop();
    recursion_stack.insert(node.to_string(), false);
}