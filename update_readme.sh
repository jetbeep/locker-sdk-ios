#!/bin/sh
set -e

# Check if asciidoctor is installed
if ! command -v asciidoctor > /dev/null; then
  echo "asciidoctor command not found. Please install asciidoctor."
  exit 1
fi

# Check if pandoc is installed
if ! command -v pandoc > /dev/null; then
  echo "pandoc command not found. Please install pandoc."
  exit 1
fi

# Temporary file for conversion
TEMP_DOCBOOK=$(mktemp)

# Convert LockerSDK_Documentation(iOS).adoc to DocBook format
asciidoctor -b docbook -d book "LockerSDK_Documentation(iOS).adoc" -o "$TEMP_DOCBOOK"

# Convert DocBook to Markdown and output to README.md
# pandoc -f docbook -t markdown -o README.md "$TEMP_DOCBOOK"
iconv -t utf-8 "$TEMP_DOCBOOK" | pandoc -f docbook -t markdown_strict --wrap=none | iconv -f utf-8 > README.md

# Clean up temporary file
rm "$TEMP_DOCBOOK"

# Add README.md to the commit if it has changed
git add README.md
