#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:-input/atomistic/input.pdb}"
OUTPUT="${2:-input/atomistic/protein_clean.pdb}"

grep -v '^HETATM' "$INPUT" > "$OUTPUT"

echo "Cleaned structure written to: $OUTPUT"
