# CABS-dock pipline

## Overview

This snakemake[^Mölder2021]-based pipeline [^Mölder2021] is designed to perform in-silico protein-peptide docking using CABS-dock [^Kurcinski2019].

## Background

### Protein-peptide docking

The protein-peptide docking is a procedure which consists in the search for near-native peptide conformations and orientations (docking poses) with respect to a target protein, where at least the structure of the target protein is known. Scoring functions are then used to rank the docking poses and assess the quality of the predicted complexes.

In general, the conformational space that both the peptide and the target protein can assume is huge. Then, a reduced representation is employed to speed up the process.

### CABS-dock

CABS-dock [^Kurcinski2019] is an efficient and fast multiscale modeling procedure based on CABS model (a coarse-grained model representation). Each amino acid is represented by up to four interaction centers, simulation dynamics are controlled by the Monte Carlo scheme, and the force field is based on statistical potentials.

## Requirements

The user must have `Snakemake` [^Mölder2021] and `python` v3.7 or higher installed, togheter with `CABS-dock` [^Kurcinski2019], `Modeller` [^Webb2016] and `DSSP` [^Kabsch1983].

## Usage

### Command line

1) clone this repository where you would like to run to the pipeline:

git clone https://github.com/ELELAB/cabsdock_production.git
cd cabsdock_production

2) edit the config.yaml and models.csv files appropriately for your system

3) run snakemake:

`snakemake [--cores NCORES]`

### Options

some widely-used snakemake options:

|Option   |Meaning   |
|---|---|
|`--cores`   |Number of cores to be used   |
|`-p`        |Print out all actions that are being performed   |
|`--dry-run` |Generate DAG but don't run rules - for testing purposes   |


### Input files

#### snakefile

It is the file that contains all the instructions to be executed. Usually, it doesn't need to be changed.

#### Apo structures

The apo structure is, by definition, the structure of the receptor protein in an unbound state with respect the interacting peptide.

All the structures that are going to be used for the docking procedure need to be collected in a folder whose path is specified in the configuration file. File names can be arbitrary.

The apo structures must be provided in PDB format.

#### Peptides

The SLiM sequences are provided in FASTA format, one file for each peptide and they need to be located in a single folder.
Each file must be named as such follows:

`[name of the peptide]_[first residue number in the FASTA sequence using the numbering of the full protein]-[last residue number, defined as per first].fasta`

Each file must contain a single entry. The content of the header can be arbitrary.

For example:

`PLEKHM1_627-646.fasta`

The file content is:

```
>PLEKHM1_627-646
VRPQQEDEWVNVQYPDQPEE
```

#### Table

It is a CSV file which uses semicolon as a column delimiter. The following information must be added:

|Entry|Meaning|Example|
|---|---|---|
|`slim_name`|It is the protein name in which the SLiM is present|p62|
|`slim_seq`|It is the first-last sequence residue numbers of the SLiM, in the main isoform Uniprot sequence of the protein it was taken from|330-349|
|`apo_structure_source`|It is the PDB ID of the complex from which the apo structure under model was taken|2ZJD|
|`apo_chain_in_source`|chain name corresponding to the apo structure that is in `apo_structure_source`|a|
|`apo_seq`|the first-last sequence residue numbers corresponding to the residues in the structure of the apo protein, Uniprot main isoform numbering|1-120|
|`apo_model_name`|name of the model we are going to use for the apo, in case e.g. we needed to do some work on the `apo_structure_source` to reconstruct missing parts|model0|
|`apo_pdb`|name of the final pdb file corresponding to the apo model that will be used by CABS-dock|apo_lc3B_p62AB.B99990001.pdb|

N.B. The first line within the table must be: 
slim_name;slim_seq;apo_structure_source;apo_chain_in_source;apo_seq;apo_model_name;apo_pdb
The following lines can contain the information for the runs: 
`p62;330-349;2ZJD;a;1-120;model0;apo_lc3B_p62AB.B99990001.pdb`

#### Configuration file

A YAML file containing the script configuration. 

The following options and parameters must be set within the configuration file:

|Generic options|Meaning|
|---|---|
|`models_csv`|It is a file ";" separated containing all the input names|
|`apo_dir`|Path of the folder containing the apo structures|
|`slim_dir`|Path of the folder containing the peptide files in fasta format|
|`out_dir`|Path of the folder where the ouputs will be written|

|CABS-dock options|Meaning|
|---|---|
|`mc_runs`|Number of Monte Carlo cycles (NUM>0)|
|`k-medoids`|Number of medoids in k-medoids clustering algorithm|
|`clustering-iterations`|Number of iterations of the clustering k-medoids algorithm|
|`saved_pdb`|Select structures to be saved in the pdb format|
|`dssp_location`|Path for the DSSP program|
|`verbose`|Controls how explicit the program output is. It ranges from 0 (only critical messages) to 4 (maximum verbosity)|
|`run_types`|The secondary structure of the peptide (`ss_def`) or the spatial restarints (`restraints`) can be added onto six differents run types (`blind`, `blind_2D`, `D-R`, `D-R_D-N`, `D-R_D-N_D2N`, `D-R_D-N_no2D`)|

N.B., The restraints can be specified in the following way. If none of those are needed, just write `null`.

    run_types:
        blind:
            ss_def: null
            restraints: null
        blind_2D:
            ss_def: 'CCCCCCCCCCCCCCCCCCCC'
            restraints: null
        D-R:
            ss_def: 'CCCCCCCCCCCCCCCCCCCC'
            restraints:
                - '--ca-rest-add 102:A 14:PEP 6.5 1.0'
        D-R_D-N:
            ss_def: 'CCCCCCCCCCCCCCCCCCCC'
            restraints:
                - '--ca-rest-add 102:A 14:PEP 6.5 1.0'
                - '--ca-rest-add 99:A 14:PEP 5.0 1.0'

### Outputs

The typical CABS-dock outputs are expected for each line within the table. The folders containing the output will be built and named with the information provided in the table.

For example, if a line appears like this:

`p62;lc3b;1-120;330-349;2ZJD;a;apo_lc3B_p62AB.B99990001.pdb`

the expected output will be located in the following path:

`lc3b/p62/p62_2ZJDa_1-120_330-349/run_types`

N.B., The `run_types` folder will be created depending on which CABS-dock's rentsraints are selected. 
 
### References

[^Mölder2021]: Mölder, F., Jablonski, K.P., Letcher, B., Hall, M.B., Tomkins-Tinch, C.H., Sochat, V., Forster, J., Lee, S., Twardziok, S.O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., Nahnsen, S., Köster, J., 2021. Sustainable data analysis with Snakemake. F1000Res 10, 33.

[^Kurcinski2019]: Mateusz Kurcinski, Maciej Pawel Ciemny, Tymoteusz Oleniecki, Aleksander Kuriata, Aleksandra E Badaczewska-Dawid, Andrzej Kolinski, Sebastian Kmiecik, CABS-dock standalone: a toolbox for flexible protein–peptide docking, Bioinformatics, Volume 35, Issue 20, 15 October 2019, Pages 4170–4172.

[^Webb2016]: Webb, B.; Sali, A. Comparative protein structure modeling using MODELLER. Curr. Protoc. Bioinforma.2016, 54, 5.6.1-5.6.37.

[^Kabsch1983]: Kabsch W, Sander C. Dictionary of protein secondary structure: pattern recognition of hydrogen-bonded and geometrical features. Biopolymers. 1983 Dec;22(12):2577-637.
