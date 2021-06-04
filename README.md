# CABS-dock pipline

## Overview

Here you can find a snakemake-based pipeline for protein-peptide docking with CABS-dock.   

## Background

### Protein-peptide docking

The protein-peptide docking is a procedure which consists in the search for near-native peptide conformations and orientations (docking poses) with respect to a target protein, where at least the structure of the target protein is known. Scoring functions are then used to rank the docking poses based on estimations of the goodness of the conformations obtained and of the binding affinity estimate of the two interacting entities. 

In general, the conformational space that both the peptide and the target protein can assume is huge. Then, a reduced representation is employed to speed up the process. 

### CABS-dock

CABS-dock is an efficient and fast multiscale modeling procedure based on CABS model (a coarse-grained model representation). Each amino acid is represented by up to four interaction centers, simulation dynamics are controlled by the Monte Carlo scheme, and the force field is based on statistical potentials.

### Snakemake

Snakemake is a python-based tool useful to create reproducible and scalable pipelines for data analyses. It is ideal for cases in which both reproducibility and generalizability of the same study and its application to several case studies are important.

## Requiremets

The user must have python v3.7 or higher installed, togheter with Modeller and DSSP softwares.

## Usage

### Command line

snakemake [--cores NCORES]

### Options

|Option   |Meaning   |
|---|---|
|--cores   |Number of cores to be used   |


### Input files

#### Snakefile

It is the file that contains all the instractions to be executed. 

#### Table

It is a CSV file **;** separated in which the following information must be added:

|Entry|Meaning|Example|
|---|---|---|
|peptide_name|It is the protein of the LIR|p62|
|template|It is the name of the LC3 protein|lc3b|
|aa_protein|It is the first-last sequence residue numbers corresponding to the residues in the structure of the receptor|1-120|
|aa_peptide|It is the first-last sequence residue numbers of the FASTA sequence we will be using for the LIR|330-349|
|run_type|It is the type of CABS-dock run, i.e. which restraints we will be using|blind|
|pdb_file|It is the PDB ID of the complex from which the apo structure under model was taken|2ZJD|
|chain|It is the chain identifier of the LIR in the original pdb_file complex|a|
|model|It is the name of the pdb file corresponding to the apo model that will be used by CABS-dock|apo_lc3B_p62AB.B99990001.pdb|

#### Configuration file

A YAML file containing the script configuration. 

The following options and parameters must be set within the configuration file:

|Option|Meaning|
|---|---|
|models_file.csv|It is a file ";" separated containing all the input names|
|apo_dir|Path of the folder containing the apo structures|
|lir_dir|Path of the folder containing the lir files in fasta format|
|out_dir|Path of the folder where the ouputs will be written|
|mc_runs|Number of Monte Carlo cycles (NUM>0)|
|k-medoids|Number of medoids in k-medoids clustering algorithm|
|clustering-iterations|Number of iterations of the clustering k-medoids algorithm|
|saved_pdb|Select structures to be saved in the pdb format|
|dssp_location|Path for the DSSP program|
|verbose|Controls how explicit the program output is. It ranges from 0 (only critical messages) to 4 (maximum verbosity)|
