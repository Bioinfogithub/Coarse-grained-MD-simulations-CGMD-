#!/bin/bash
#PBS -N cgmd
#PBS -o cgmd_output.log
#PBS -e cgmd_error.log
#PBS -q workq
#PBS -l nodes=1:ppn=32
#PBS -j oe

cd "$PBS_O_WORKDIR"

# Update this module name for your HPC environment.
module load gromacs-gpu-2023

gmx_mpi grompp \
    -f mdp/md.mdp \
    -c npt.gro \
    -t npt.cpt \
    -p topol.top \
    -o md.tpr \
    -n index.ndx

gmx_mpi mdrun -v -deffnm md
