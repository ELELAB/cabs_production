# CABS-dock pipline

## Overview

Here you can find a snakemake-based pipeline for protein-peptide docking with CABS-dock.   

## Background

### Protein-peptide docking

The protein-peptide docking is a procedure which consists in the search for near-native peptide conformations and orientations (docking poses) with respect to a target protein, where at least the structure of the target protein is known. Scoring functions are then used to rank the docking poses based on estimations of the goodness of the conformations obtained and of the binding affinity estimate of the two interacting entities. 

In general, the conformational space that both the peptide and the target protein can assume is huge. Then, a reduced representation is employed to speed up teh process. 

### CABS-dock

CABS-dock is an efficient and fast multiscale modeling procedure based on CABS model (a coarse-grained model representation). Each amino acid is represented by up to four interaction centers, simulation dynamics are controlled by the Monte Carlo scheme, and the force field is based on statistical potentials.

### Snakemake

Snakemake is a python-based tool useful to create reproducible and scalable pipelines for data analyses. It is ideal for cases in which both reproducibility and generalizability of the same study and its application to several case studies are important.

## Requiremets

The user must have python v3.7 or higher installed, togheter with Modeller and DSSP softwares.

## Usage

# Command line

snakemake [--cores NCORES]

# Options

|Option   |Meaning   |
|---|---|
|--cores   |Number of cores to be used   |

