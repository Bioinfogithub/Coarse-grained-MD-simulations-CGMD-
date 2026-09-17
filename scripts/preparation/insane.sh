#!/usr/bin/env bash
set -euo pipefail

CG_STRUCTURE="${1:-input/cg/protein_cg.pdb}"
SYSTEM="${2:-input/cg/system.gro}"
TOPOLOGY="${3:-topology/protein/topol.top}"

# Adjust box size, solvent and salt for your actual system.
insane \
    -f "$CG_STRUCTURE" \
    -o "$SYSTEM" \
    -p "$TOPOLOGY" \
    -d 7 \
    -sol W \
    -salt 0.15
