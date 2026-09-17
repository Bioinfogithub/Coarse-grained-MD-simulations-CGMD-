#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:-input/atomistic/protein_clean.pdb}"
OUTPUT="${2:-input/cg/protein_cg.pdb}"
TOPO="${3:-topology/protein/topol.top}"
DSSP="${DSSP:-$(command -v mkdssp || command -v dssp || true)}"

if [[ -z "$DSSP" ]]; then
    echo "ERROR: DSSP/mkdssp was not found. Set DSSP=/path/to/mkdssp."
    exit 1
fi

martinize2 \
    -f "$INPUT" \
    -dssp "$DSSP" \
    -x "$OUTPUT" \
    -o "$TOPO" \
    -ff martini3001 \
    -scfix \
    -cys auto \
    -p backbone \
    -elastic \
    -ef 700.0 \
    -el 0.5 \
    -eu 0.9
