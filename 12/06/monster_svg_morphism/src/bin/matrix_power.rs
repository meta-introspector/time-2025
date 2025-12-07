use nalgebra::{DMatrix};
use monster_svg_morphism::matrix_form;

fn main() {
    println!("Starting iterative matrix multiplication for the Monster Matrix.");

    let initial_matrix = matrix_form::construct_monster_matrix();
    let mut current_matrix = initial_matrix.clone(); // Start with M^1

    println!("\n--- Iteration 1 (Initial Matrix) ---");
    println!("{}", current_matrix);

    // Perform a few iterations of multiplication
    let num_iterations = 5;
    for i in 2..=num_iterations {
        // M^k = M^(k-1) * M
        current_matrix = &current_matrix * &initial_matrix;
        println!("\n--- Iteration {} ---", i);
        println!("{}", current_matrix);
    }

    println!("\nIterative matrix multiplication complete.");
}
