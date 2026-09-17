# Coarse-Grained Molecular Dynamics Simulations (CGMD)

A reproducible workflow for performing **coarse-grained molecular dynamics (CGMD) simulations of proteins using the Martini 3 coarse-grained force field and GROMACS**.

This repository documents the complete computational workflow from atomistic protein structure preparation and Martini 3 coarse-grained model generation to topology generation, system construction, solvation and ionization, energy minimization, NPT equilibration, production CGMD simulation, HPC execution, trajectory processing, and structural and dynamical analysis.

---

## Workflow

```text
Atomistic Protein Structure
            |
            v
Structure Preparation
            |
            v
Martini 3 CG Model Generation
            |
            v
CG Topology Generation
            |
            v
Simulation Box Construction
            |
            v
CG Solvation + Ion Addition
            |
            v
Energy Minimization
            |
            v
NPT Equilibration
            |
            v
Production CGMD Simulation
            |
            v
HPC Execution
            |
            v
Trajectory Processing
            |
            v
Structural & Dynamical Analysis
            |
      +-----+------+------+------+
      |            |             |
     RMSD         RMSF           Rg
      |            |             |
      +------------+-------------+
                   |
                  SASA
                   |
                   v
          Additional Analysis
                   |
                   v
          Results & Interpretation
```

## Software and Computational Tools

| Tool | Purpose |
|---|---|
| **GROMACS** | Molecular dynamics simulation and trajectory analysis |
| **Martini 3** | Coarse-grained molecular force field |
| **Martinize2** | Conversion of atomistic protein structures to CG representation |
| **Vermouth** | Molecular topology generation used by Martinize2 |
| **DSSP / mkdssp** | Secondary-structure assignment |
| **Insane** | Construction, solvation, and ionization of Martini systems |
| **Python 3** | Data processing, analysis, and visualization |
| **Bash** | Workflow automation |
| **Linux** | Computational environment |
| **VMD** | Molecular visualization and trajectory inspection |
| **PyMOL** | Structural visualization |
| **HPC/GPU cluster** | Long-timescale production simulations |

## Martini 3 Coarse-Grained Force Field

Martini 3 represents molecular systems at reduced resolution by grouping atoms into coarse-grained beads. This reduces computational cost and enables investigation of biomolecular processes at longer timescales and larger spatial scales than conventional all-atom simulations.

For protein simulations, the atomistic structure is converted into a Martini-compatible CG representation using Martinize2/Vermouth.

## Repository Structure

```text
Coarse-Grained-MD-Simulations-CGMD/
|
|-- README.md
|-- .gitignore
|
|-- input/
|   |-- atomistic/
|   |   `-- README.md
|   |
|   `-- cg/
|       `-- README.md
|
|-- topology/
|   |-- martini/
|   |   `-- README.md
|   |
|   `-- protein/
|       `-- README.md
|
|-- mdp/
|   |-- minim.mdp
|   |-- npt.mdp
|   `-- md.mdp
|
|-- scripts/
|   |-- README.md
|   |
|   |-- preparation/
|   |   |-- clean_structure.sh
|   |   |-- martinize2.sh
|   |   `-- insane.sh
|   |
|   |-- production/
|   |   `-- run_production.sh
|   |
|   `-- analysis/
|       |-- rmsd.sh
|       |-- rmsf.sh
|       |-- radius_of_gyration.sh
|       `-- sasa.sh
|
|-- hpc/
|   `-- production.sh
|
|-- analysis/
|   |-- README.md
|   |-- rmsd/
|   |-- rmsf/
|   |-- rg/
|   `-- sasa/
|
`-- results/
    `-- README.md
```

# Complete CGMD Workflow

## 1. Input Structure Preparation

The workflow starts from an atomistic protein structure, typically in PDB or GRO format.

Place the starting structure in:

```text
input/atomistic/
```

Example:

```text
input/
`-- atomistic/
    `-- protein.pdb
```

Before coarse-graining, inspect the structure for missing residues, alternate conformations, incorrect chain identifiers, unwanted molecules, and non-standard residues.

Example preparation script:

```bash
#!/bin/bash

INPUT="input/atomistic/protein.pdb"
OUTPUT="input/atomistic/protein_clean.pdb"

# Perform structure-specific cleaning here.
# Modify this section according to the input structure.

cp "$INPUT" "$OUTPUT"

echo "Prepared structure: $OUTPUT"
```

Save as:

```text
scripts/preparation/clean_structure.sh
```

Run:

```bash
chmod +x scripts/preparation/clean_structure.sh
./scripts/preparation/clean_structure.sh
```

## 2. Generate the Martini 3 CG Model

Convert the prepared atomistic structure into a Martini 3 coarse-grained model using Martinize2/Vermouth.

```bash
martinize2 \
    -f protein_clean.pdb \
    -dssp /path/to/mkdssp \
    -x protein-CG.pdb \
    -o topol.top \
    -ff martini3001 \
    -scfix \
    -cys auto \
    -p backbone \
    -elastic \
    -ef 700.0 \
    -el 0.5 \
    -eu 0.9
```

Important options:

| Option | Description |
|---|---|
| `-f` | Atomistic input structure |
| `-dssp` | DSSP executable |
| `-x` | Output CG structure |
| `-o` | Output topology |
| `-ff` | Martini force field |
| `-scfix` | Side-chain correction |
| `-cys auto` | Automatic cysteine treatment |
| `-p backbone` | Backbone position restraints |
| `-elastic` | Elastic-network representation |
| `-ef` | Elastic force constant |
| `-el` | Lower elastic cutoff |
| `-eu` | Upper elastic cutoff |

Example script:

```bash
#!/bin/bash

INPUT="input/atomistic/protein_clean.pdb"
OUTPUT="input/cg/protein-CG.pdb"
TOPOLOGY="topology/protein/topol.top"
DSSP="/path/to/mkdssp"

martinize2 \
    -f "$INPUT" \
    -dssp "$DSSP" \
    -x "$OUTPUT" \
    -o "$TOPOLOGY" \
    -ff martini3001 \
    -scfix \
    -cys auto \
    -p backbone \
    -elastic \
    -ef 700.0 \
    -el 0.5 \
    -eu 0.9
```

Save as:

```text
scripts/preparation/martinize2.sh
```

Run:

```bash
chmod +x scripts/preparation/martinize2.sh
./scripts/preparation/martinize2.sh
```

Inspect the generated CG structure using VMD or PyMOL.

## 3. CG Topology Generation and Verification

Martinize2 generates topology information required to describe the CG protein.

Typical files include:

```text
topol.top
protein.itp
```

Organize topology files under:

```text
topology/
|-- martini/
`-- protein/
```

Verify that:

- Martini force-field files are included.
- Protein topology files are present.
- Molecule names are consistent.
- The number of molecules is correct.
- Required `.itp` files are included.
- The topology can be processed by `gmx grompp`.

## 4. Simulation Box Construction

After generation of the CG protein, construct the simulation box.

```text
CG Protein
    |
    v
Simulation Box
    |
    v
CG Water
    |
    v
Ions
    |
    v
Complete CG System
```

The box should provide sufficient space around the protein to avoid undesirable interactions with periodic images.

## 5. CG Solvation and Ion Addition

Use Insane to construct the solvated and ionized Martini system.

```bash
insane \
    -f protein-CG.pdb \
    -o system.gro \
    -p topol.top \
    -d 7 \
    -sol W \
    -salt 0.15
```

Parameters:

| Parameter | Description |
|---|---|
| `-f` | CG protein structure |
| `-o` | Output system |
| `-p` | Topology file |
| `-d` | Protein-to-box boundary distance |
| `-sol W` | Martini water |
| `-salt 0.15` | Salt concentration |

Example script:

```bash
#!/bin/bash

CG_STRUCTURE="input/cg/protein-CG.pdb"
SYSTEM="input/cg/system.gro"
TOPOLOGY="topology/protein/topol.top"

insane \
    -f "$CG_STRUCTURE" \
    -o "$SYSTEM" \
    -p "$TOPOLOGY" \
    -d 7 \
    -sol W \
    -salt 0.15
```

Save as:

```text
scripts/preparation/insane.sh
```

Run:

```bash
chmod +x scripts/preparation/insane.sh
./scripts/preparation/insane.sh
```

Inspect the final system and verify the topology.

# Energy Minimization

## 6. Energy Minimization

Energy minimization removes unfavorable contacts and excessive forces introduced during system construction.

Parameters:

```text
mdp/minim.mdp
```

Prepare:

```bash
gmx grompp \
    -f mdp/minim.mdp \
    -c system.gro \
    -p topol.top \
    -o em.tpr
```

Run:

```bash
gmx mdrun \
    -deffnm em
```

Typical outputs:

```text
em.tpr
em.gro
em.edr
em.log
```

Inspect the minimized structure before equilibration.

# NPT Equilibration

## 7. NPT Equilibration

Equilibrate the minimized system under the NPT ensemble.

Parameters:

```text
mdp/npt.mdp
```

Prepare:

```bash
gmx grompp \
    -f mdp/npt.mdp \
    -c em.gro \
    -p topol.top \
    -o npt.tpr
```

Run:

```bash
gmx mdrun \
    -deffnm npt
```

Monitor:

```text
Temperature
Pressure
Density
Potential Energy
Box dimensions
```

Proceed to production only after reaching an appropriate equilibrated state.

# Production CGMD

## 8. Production CGMD Simulation

Production parameters:

```text
mdp/md.mdp
```

Prepare:

```bash
gmx grompp \
    -f mdp/md.mdp \
    -c npt.gro \
    -p topol.top \
    -o md.tpr
```

Run:

```bash
gmx mdrun \
    -deffnm md
```

Typical outputs:

```text
md.tpr
md.xtc
md.edr
md.log
md.gro
md.cpt
```

The production trajectory `md.xtc` is used for downstream analysis.

# HPC Execution

## 9. Run Production CGMD on HPC

Long-timescale simulations can be executed on an HPC cluster.

Example PBS-style script:

```bash
#!/bin/bash

# Load GROMACS
module load gromacs-gpu-2023

# Run production CGMD
gmx_mpi mdrun \
    -deffnm md
```

Save as:

```text
hpc/production.sh
```

Submit:

```bash
qsub hpc/production.sh
```

Document:

```text
Scheduler
CPU cores
GPU
Memory
Walltime
GROMACS version
MPI configuration
GPU configuration
```

HPC settings should be adapted to the target cluster.

# Trajectory Processing

## 10. Periodic Boundary and Trajectory Processing

Before analysis, periodic-boundary artifacts and molecular translation/rotation may need correction.

```bash
gmx trjconv \
    -s md.tpr \
    -f md.xtc \
    -o md_processed.xtc \
    -pbc mol \
    -center
```

Depending on the system, processing may include:

```text
Periodic-boundary correction
Molecule centering
Reference fitting
Removal of translation
Removal of rotation
Frame extraction
Trajectory subsampling
```

Use consistent processing for systems being compared.

# Structural and Dynamical Analysis

## 11. RMSD Analysis

Root-mean-square deviation (RMSD) measures structural deviation relative to a reference structure.

```bash
gmx rms \
    -s md.tpr \
    -f md_processed.xtc \
    -o analysis/rmsd/rmsd.xvg
```

Example script:

```bash
#!/bin/bash

gmx rms \
    -s md.tpr \
    -f md_processed.xtc \
    -o analysis/rmsd/rmsd.xvg
```

Save as:

```text
scripts/analysis/rmsd.sh
```

RMSD can assess:

- Structural stability
- Equilibration
- Global conformational changes
- Structural deviations
- Differences between systems

## 12. RMSF Analysis

Root-mean-square fluctuation (RMSF) measures local fluctuations.

```bash
gmx rmsf \
    -s md.tpr \
    -f md_processed.xtc \
    -o analysis/rmsf/rmsf.xvg
```

Example script:

```bash
#!/bin/bash

gmx rmsf \
    -s md.tpr \
    -f md_processed.xtc \
    -o analysis/rmsf/rmsf.xvg
```

Save as:

```text
scripts/analysis/rmsf.sh
```

RMSF can identify:

- Flexible loops
- Mobile termini
- Rigid regions
- Highly fluctuating regions
- Changes in local flexibility

## 13. Radius of Gyration

Radius of gyration (Rg) measures overall protein compactness.

```bash
gmx gyrate \
    -s md.tpr \
    -f md_processed.xtc \
    -o analysis/rg/gyrate.xvg
```

Example script:

```bash
#!/bin/bash

gmx gyrate \
    -s md.tpr \
    -f md_processed.xtc \
    -o analysis/rg/gyrate.xvg
```

Save as:

```text
scripts/analysis/radius_of_gyration.sh
```

Rg can investigate:

- Protein compactness
- Expansion
- Contraction
- Large-scale rearrangements
- Differences between variants

## 14. Solvent-Accessible Surface Area

SASA measures molecular surface accessible to solvent.

```bash
gmx sasa \
    -s md.tpr \
    -f md_processed.xtc \
    -o analysis/sasa/sasa.xvg
```

Example script:

```bash
#!/bin/bash

gmx sasa \
    -s md.tpr \
    -f md_processed.xtc \
    -o analysis/sasa/sasa.xvg
```

Save as:

```text
scripts/analysis/sasa.sh
```

SASA can characterize:

- Solvent exposure
- Surface rearrangements
- Protein compactness
- Exposure of buried regions
- Conformational changes

# Additional Analyses

## 15. Principal Component Analysis

PCA can identify dominant collective motions:

```text
CGMD trajectory
       |
       v
Covariance matrix
       |
       v
Eigenvectors / Eigenvalues
       |
       v
Dominant collective motions
```

PCA can characterize large-scale conformational changes and dominant dynamical modes.

## 16. Dynamic Cross-Correlation Analysis

Dynamic cross-correlation analysis can identify correlated and anticorrelated motions between regions.

Applications include:

- Domain communication
- Coupled motions
- Correlated structural changes
- Anticorrelated movements

## 17. Contact Analysis

Contact analysis can monitor:

```text
Intramolecular contacts
Inter-domain contacts
Protein-protein contacts
Protein-peptide contacts
Contact persistence
Contact formation/loss
```

For complexes, contact analysis can identify dynamically stable and transient interaction regions.

## 18. Distance Analysis

Monitor distances between selected residues/beads, domains, or molecules.

```text
Trajectory
    |
    v
Selected bead pairs
    |
    v
Distance calculation
    |
    v
Distance vs time
```

Applications include:

- Domain movements
- Interface dynamics
- Binding-site rearrangements
- Conformational transitions

## 19. Cluster Analysis

Trajectory clustering can identify representative conformational states.

```text
CGMD trajectory
       |
       v
Structural similarity
       |
       v
Clustering
       |
       v
Representative conformations
```

Representative structures can be visualized using VMD or PyMOL.

## 20. Free-Energy Landscape Analysis

Free-energy landscapes can be constructed using:

```text
RMSD
Radius of gyration
PCA coordinates
Inter-domain distance
Intermolecular distance
```

Conceptual workflow:

```text
Trajectory
    |
    v
Collective variables
    |
    v
Population distribution
    |
    v
Free-energy calculation
    |
    v
Free-energy landscape
```

These can help identify:

- Dominant conformational states
- Metastable states
- Conformational transitions
- Low-population states

# Quality Assessment

## 21. Structural Stability

Assess trajectories using complementary descriptors:

```text
RMSD
RMSF
Radius of gyration
SASA
```

No single metric should be interpreted in isolation.

## 22. Thermodynamic and Simulation Stability

During minimization and equilibration, monitor:

```text
Potential energy
Temperature
Pressure
Density
Box dimensions
```

These quantities help establish whether the system has reached a suitable simulation regime.

## 23. Conformational Stability

Production trajectories can be evaluated using:

```text
RMSD
RMSF
Rg
SASA
PCA
Clustering
Contact analysis
Free-energy landscapes
```

Together these provide a broader description of the sampled conformational ensemble.

# AAMD and CGMD

## 24. Comparison of AAMD and CGMD

| Feature | AAMD | CGMD |
|---|---|---|
| Representation | Atomistic | Coarse-grained |
| Spatial resolution | High | Reduced |
| Computational cost | Higher | Lower |
| Accessible timescale | Generally shorter | Generally longer |
| Large-scale motions | More computationally demanding | More accessible |
| Atomic interactions | Detailed | Effective/coarse-grained |
| Local structural detail | High | Reduced |
| Large conformational transitions | More expensive | More accessible |

AAMD and CGMD provide complementary information.

AAMD provides detailed atomic-level information, while CGMD facilitates investigation of larger-scale conformational behavior and longer-timescale dynamics.

# Multiscale Simulation

## 25. Integration with AAMD

CGMD can be incorporated into a multiscale workflow:

```text
Protein Sequence
       |
       v
Sequence Analysis / Design
       |
       v
Structure Prediction
       |
       v
Candidate Filtering
       |
       v
Molecular Docking
       |
       +-------------------+
       |                   |
       v                   v
      AAMD                CGMD
       |                   |
       v                   v
Atomic-level        Long-timescale
information            dynamics
       |                   |
       +---------+---------+
                 |
                 v
        Multiscale Analysis
                 |
                 v
       Candidate Prioritization
```

This framework connects sequence-level design with structural and dynamical characterization.

# Reproducibility

## 26. Reproducible Workflow

The repository separates:

```text
Input Structure
       |
       v
Structure Preparation
       |
       v
CG Model Generation
       |
       v
Topology Generation
       |
       v
System Construction
       |
       v
Solvation and Ionization
       |
       v
Energy Minimization
       |
       v
NPT Equilibration
       |
       v
Production CGMD
       |
       v
Trajectory Processing
       |
       v
Structural Analysis
       |
       v
Results
```

For each system document:

- Starting structure
- Protein sequence
- PDB identifier/source
- Chain information
- Structure preparation procedure
- Martini version
- Martinize2/Vermouth version
- DSSP version
- Insane version
- GROMACS version
- Box dimensions
- Solvent composition
- Ion concentration
- Temperature
- Pressure
- Time step
- Minimization settings
- Equilibration duration
- Production duration
- Number of replicas
- HPC configuration
- Analysis procedures

All simulation parameters should be maintained under version control.

# Requirements

## 27. Software Requirements

### Core software

```text
GROMACS
Martini 3
Martinize2
Vermouth
DSSP / mkdssp
Insane
Python 3
Bash
Linux
```

### Visualization

```text
VMD
PyMOL
```

### Python analysis packages

```text
numpy
pandas
matplotlib
scipy
```

Install additional packages as required by individual analysis scripts.

# Complete End-to-End Commands

## Prepare structure

```bash
./scripts/preparation/clean_structure.sh
```

## Generate CG model

```bash
./scripts/preparation/martinize2.sh
```

## Build solvated/ionized system

```bash
./scripts/preparation/insane.sh
```

## Energy minimization

```bash
gmx grompp \
    -f mdp/minim.mdp \
    -c system.gro \
    -p topol.top \
    -o em.tpr

gmx mdrun \
    -deffnm em
```

## NPT equilibration

```bash
gmx grompp \
    -f mdp/npt.mdp \
    -c em.gro \
    -p topol.top \
    -o npt.tpr

gmx mdrun \
    -deffnm npt
```

## Production preparation

```bash
gmx grompp \
    -f mdp/md.mdp \
    -c npt.gro \
    -p topol.top \
    -o md.tpr
```

## Production CGMD

```bash
gmx mdrun \
    -deffnm md
```

## HPC production

```bash
qsub hpc/production.sh
```

## Process trajectory

```bash
gmx trjconv \
    -s md.tpr \
    -f md.xtc \
    -o md_processed.xtc \
    -pbc mol \
    -center
```

## RMSD

```bash
./scripts/analysis/rmsd.sh
```

## RMSF

```bash
./scripts/analysis/rmsf.sh
```

## Radius of gyration

```bash
./scripts/analysis/radius_of_gyration.sh
```

## SASA

```bash
./scripts/analysis/sasa.sh
```

## Visualization

Inspect trajectories and representative structures using:

```text
VMD
PyMOL
```

# Scientific Applications

## 28. Applications

This workflow can be applied to:

### Protein Dynamics

- Conformational flexibility
- Large-scale structural rearrangements
- Domain movements
- Long-timescale dynamics

### Protein Stability

- Structural compactness
- Conformational fluctuations
- Variant comparison
- Mutation-induced changes

### Protein-Protein Interactions

- Interface dynamics
- Contact persistence
- Intermolecular distances
- Domain rearrangements
- Complex stability

### Protein-Peptide Interactions

- Peptide binding behavior
- Binding-site dynamics
- Protein-peptide contacts
- Conformational changes

### Computational Protein Design

CGMD can be incorporated downstream of computational protein-design workflows:

```text
Sequence Analysis
       |
       v
AI/ML-Based Sequence Design
       |
       v
Structure Prediction
       |
       v
Candidate Filtering
       |
       v
Molecular Docking
       |
       v
All-Atom MD
       |
       v
Coarse-Grained MD
       |
       v
Multiscale Structural Analysis
       |
       v
Candidate Prioritization
```

# Best Practices

1. Inspect the starting structure before coarse-graining.
2. Remove unwanted structural components where appropriate.
3. Verify the generated CG structure.
4. Check the generated topology carefully.
5. Confirm all Martini force-field files are correctly included.
6. Verify simulation-box dimensions.
7. Confirm solvent and ion composition.
8. Perform energy minimization before equilibration.
9. Monitor temperature, pressure, density, and energy during equilibration.
10. Confirm equilibration before production.
11. Process trajectories consistently across systems.
12. Use multiple structural descriptors rather than a single metric.
13. Store GROMACS `.mdp` files under version control.
14. Document GROMACS and Martini versions.
15. Record HPC configuration.
16. Keep analysis scripts under version control.
17. Store representative structures and figures separately from large trajectories.
18. Avoid committing large binary simulation files to GitHub.

# Large Simulation Files and GitHub

Molecular dynamics simulations generate large binary files that should generally not be committed directly to a standard GitHub repository.

Commonly excluded files:

```text
*.xtc
*.trr
*.tpr
*.edr
*.cpt
*.log
```

Generated coordinate files can also be excluded depending on repository size and workflow.

For large datasets requiring version control, Git LFS or external data storage may be used.

# Suggested .gitignore

```gitignore
# GROMACS binary/output files
*.xtc
*.trr
*.tpr
*.edr
*.cpt
*.log

# Temporary files
*.tmp
*.bak
*~

# Python cache
__pycache__/
*.pyc

# Analysis temporary files
*.xvg~
```

# Scientific Workflow Summary

```text
                ATOMISTIC STRUCTURE
                        |
                        v
              STRUCTURE PREPARATION
                        |
                        v
               MARTINI 3 MODEL
                        |
                        v
               TOPOLOGY GENERATION
                        |
                        v
                SYSTEM BUILDING
                        |
                        v
              SOLVATION + IONS
                        |
                        v
              ENERGY MINIMIZATION
                        |
                        v
                NPT EQUILIBRATION
                        |
                        v
               PRODUCTION CGMD
                        |
                        v
                 HPC EXECUTION
                        |
                        v
              TRAJECTORY PROCESSING
                        |
                        v
              STRUCTURAL ANALYSIS
                        |
       +----------------+----------------+
       |                |                |
      RMSD             RMSF              Rg
       |                |                |
       +----------------+----------------+
                        |
                       SASA
                        |
                        v
                ADVANCED ANALYSIS
                        |
          +-------------+-------------+
          |             |             |
         PCA         Contacts      Clustering
          |             |             |
          +-------------+-------------+
                        |
                        v
              CONFORMATIONAL STATES
                        |
                        v
              RESULTS & INTERPRETATION
```

# References

### Martini 3

Souza, P. C. T.; Alessandri, R.; Barnoud, J.; et al. Martini 3: A General Purpose Force Field for Coarse-Grained Molecular Dynamics.

*Nature Methods* **2021**, *18*, 382–388.

### Martini Force Field

Marrink, S. J.; Risselada, H. J.; Yefimov, S.; Tieleman, D. P.; de Vries, A. H. The MARTINI Force Field: Coarse Grained Model for Biomolecular Simulations.

*Journal of Physical Chemistry B* **2007**, *111*, 7812–7824.

### GROMACS

Abraham, M. J.; Murtola, T.; Schulz, R.; et al. GROMACS: High Performance Molecular Simulations through Multi-Level Parallelism.

*SoftwareX* **2015**, *1–2*, 19–25.

### Martini 3 / GROMACS Tutorial

GROMACS Tutorial: Coarse-Grained Simulations with the Martini 3 Force Field.

https://www.compchems.com/gromacs-tutorial-coarse-grained-simulations-with-martini-3-force-field/

# Author

**Amar Jeet Yadav**

PhD Research Scholar  
School of Biochemical Engineering  
Indian Institute of Technology (BHU), Varanasi, India

### Research Interests

```text
Computational Biology
Structural Bioinformatics
Computational Protein Design
Protein & Peptide Design
AI/ML for Biomolecular Modelling
Molecular Docking
Protein-Protein Interactions
All-Atom Molecular Dynamics
Coarse-Grained Molecular Dynamics
Protein Structure-Dynamics-Function Relationships
```

# Repository Purpose

This repository provides a research-oriented and reproducible framework for **Martini 3 coarse-grained molecular dynamics simulations using GROMACS**.

The workflow connects atomistic structure preparation, coarse-grained model generation, topology generation, system construction, molecular simulation, HPC execution, trajectory processing, and structural/dynamical analysis.

The framework can be adapted for protein dynamics, protein stability, protein-protein interactions, protein-peptide systems, computational protein design, and multiscale molecular simulation studies.

# License

This repository is intended primarily for academic and research purposes.

Please cite the relevant Martini, GROMACS, software, and methodological references when using or adapting this workflow.
