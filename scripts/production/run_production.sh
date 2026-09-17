#!/usr/bin/env bash
set -euo pipefail

TOPOLOGY="${TOPOLOGY:-topol.top}"
INDEX="${INDEX:-index.ndx}"

gmx_mpi grompp \
    -f mdp/md.mdp \
    -c npt.gro \
    -t npt.cpt \
    -p "$TOPOLOGY" \
    -o md.tpr \
    -n "$INDEX"

gmx_mpi mdrun -v -deffnm md
