#!/usr/bin/env bash
set -euo pipefail
mkdir -p analysis/sasa

gmx_mpi sasa     -s md.tpr     -f md.xtc     -o analysis/sasa/sasa.xvg
