# SVG Renamer

A simple tool to rename group (`<g>`) elements in an SVG file based on their text content.

## Usage

```sh
cargo run --package svg-renamer -- <input_svg> <output_svg> [max_length]
```

-   `<input_svg>`: Path to the input SVG file.
-   `<output_svg>`: Path to the output SVG file.
-   `[max_length]` (optional): Maximum length of the new group IDs. If the generated ID is longer than this, it will be truncated and a hash will be appended.

The tool will create the output directory for the output file if it doesn't exist.
