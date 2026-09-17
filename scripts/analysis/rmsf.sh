#!/usr/bin/env bash
set -euo pipefail
mkdir -p analysis/rmsf

# Select the BB group when prompted.
gmx_mpi rmsf     -s md.tpr     -f md.xtc     -o analysis/rmsf/rmsf.xvg     -res
