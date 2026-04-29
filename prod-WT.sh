#!/bin/bash
#PBS -N md
#PBS -o output.log
#PBS -e err.log
#PBS -q workq
#PBS -l nodes=1:ppn=16
#PBS -j oe

cd $PBS_O_WORKDIR
module load gromacs-gpu-2023

gmx_mpi mdrun -deffnm md

