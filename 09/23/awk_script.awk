BEGIN {
  ORS = "\n"
}

{
  line = $0

  # Add newline after path/type opening brace
  gsub(/"?: {/, "\"?: {\n", line)

  # Add newline after n-gram type opening brace
  gsub(/([0-9]-gram): {/, "\\1: {\n", line)

  # Add newline after closing brace of a block, before next key
  gsub(/}, "/, "},\n\"", line) # Corrected

  # Add newline after closing brace of a block, before next comma
  gsub(/},/, "},\n", line)

  # Add newline between two closing braces
  gsub(/}}/, "}\n}", line)

  # Split n-gram lists by ", "
  gsub(/, /, ",\n", line)

  # Print the modified line, unless it's empty
  if (line !~ /^\s*$/) {
    print line
  }
}
