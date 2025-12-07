# monster_svg_morphism

`monster_svg_morphism` is a Rust crate that provides tools for parsing, analyzing, and transforming SVG (Scalable Vector Graphics) files based on a conceptual mapping to elements of the Monster Group.

## Purpose

This project allows for the programmatic manipulation of SVG files, interpreting their structural components through the lens of Monster Group theory. The primary executable within this crate currently demonstrates a "morphism" by assigning distinct colors to SVG elements based on their mapped `MonsterElementKind`.

## Structure

The `monster_svg_morphism` project is structured as a Rust library with an associated binary:

-   **Library (`src/lib.rs`):** Defines the core data structures, traits, and logic for representing SVG elements, performing Monster Group mapping, and managing related utilities. This library is designed for modularity, with types and traits organized into their respective sub-modules:
    -   `src/types/`: Contains individual definitions for SVG elements (e.g., `Rect`, `Circle`, `Svg`), utility types (e.g., `BoundingBox`, `Color`, `Style`), and Monster Group related enums (`MonsterElementKind`).
    -   `src/traits/`: Defines traits like `SvgComponent` and `MapsToMonster` that enforce common behavior and provide the Monster Group mapping functionality for SVG elements.

-   **Binary (`src/main.rs`):** An executable application that utilizes the `monster_svg_morphism` library. It reads an input SVG file, applies the defined "morphism" (currently a color transformation based on `MonsterElementKind`), and writes the transformed SVG to an output file.

## Usage

### Building

To build the project, navigate to the `monster_svg_morphism` directory and run:

```bash
cargo build --release
```

### Running the SVG Morphism Tool

The compiled binary `monster_svg_morphism` takes two command-line arguments: the path to the input SVG file and the path for the output (transformed) SVG file.

```bash
./target/release/monster_svg_morphism <input.svg> <output.svg>
```

**Example:**

```bash
./target/release/monster_svg_morphism input.svg output_morphed.svg
```

This will read `input.svg`, color its elements according to their `MonsterElementKind` mapping, and save the result as `output_morphed.svg`.

## Monster Group Mapping (Morphism)

The core idea of this project is to associate components of an SVG document with elements of the Monster Group. Each `MonsterElementKind` represents a symbolic archetype. The binary currently visualizes this mapping by assigning a unique color to each `MonsterElementKind` found in the SVG, making the underlying structure and its Monster Group interpretation visible.

## Future Enhancements

Future enhancements could include:
-   More complex "morphisms" (transformations) based on Monster Group properties.
-   Advanced SVG parsing and rendering capabilities.
-   Integration with other mathematical or symbolic systems.
