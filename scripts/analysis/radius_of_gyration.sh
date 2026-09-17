#!/usr/bin/env bash
set -euo pipefail
mkdir -p analysis/rg

gmx_mpi gyrate     -s md.tpr     -f md.xtc     -o analysis/rg/radius_of_gyration.xvg
