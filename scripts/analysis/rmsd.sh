#!/usr/bin/env bash
set -euo pipefail
mkdir -p analysis/rmsd

# Select the BB group when prompted.
gmx_mpi rms     -s md.tpr     -f md.xtc     -o analysis/rmsd/rmsd.xvg     -tu ns
