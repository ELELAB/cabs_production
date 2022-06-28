# CABS-dock pipeline

## Overview

This snakemake[^Mölder2021]-based pipeline [^Mölder2021] is designed to perform in-silico protein-peptide docking using CABS-dock [^Kurcinski2019].
In particular, it focuses on docking peptides harboring short linear motifs (SLiMs) on apo structures of proteins of interest.

## Background

### Protein-peptide docking

The protein-peptide docking is a procedure which consists in the search for near-native peptide conformations and orientations (docking poses) with respect to a target protein, where at least the structure of the target protein is known. Scoring functions are then used to rank the docking poses and assess the quality of the predicted complexes.

In general, the conformational space that both the peptide and the target protein can assume is huge. Then, a reduced representation is employed to speed up the process.

### CABS-dock

CABS-dock [^Kurcinski2019] is an efficient and fast multiscale modeling procedure based on CABS model (a coarse-grained model representation). Each amino acid is represented by up to four interaction centers, simulation dynamics are controlled by the Monte Carlo scheme, and the force field is based on statistical potentials.

## Requirements

The user must have `Snakemake` [^Mölder2021] and `python` v3.7 or higher installed, togheter with `CABS-dock` [^Kurcinski2019], `Modeller` [^Webb2016] and `DSSP` [^Kabsch1983].

The user will also need to provide:

- a directory with PDB files of the apo structure for the docking. These need also to be specified in the models.csv file;
- a directory with FASTA files contaning the sequence of the SLiM of interest;
- an appriopriately formatted csv and config.yaml file.

More details to follow.

## Usage

1. Clone this repository where you would like to run to the pipeline:

`git clone https://github.com/ELELAB/cabsdock_production.git`
`cd cabsdock_production`

2. Edit the config.yaml and models.csv files appropriately for your system.

3. run snakemake:

`snakemake [--cores NCORES]`

### Options

Some widely-used snakemake options that might come useful:

|Option   |Meaning   |
|---|---|
|`--cores`   |Number of cores to be used|
|`-p`        |Print out all actions that are being performed|
|`--dry-run` |Generate DAG but don't run rules - for testing purposes|


### Design of input files

#### snakefile

It is the file that contains all the instructions to be executed. Usually, it doesn't need to be changed.

#### Apo structures

The apo structure is, by definition, the structure of the receptor protein in an unbound state with respect the interacting peptide.

All the structures that are going to be used for the docking procedure need to be collected in a folder whose path is specified in the configuration file. File names can be arbitrary.

The apo structures must be provided in PDB format.

#### Peptides

The sequences of SLiMs are provided in FASTA format, one file for each peptide and they need to be located in a single folder.
Each file must be named as such follows:

`[name of the peptide]_[first residue number in the FASTA sequence of the SLiM using the numbering of the full protein]-[last residue number, defined as per first].fasta`

Each file must contain a single entry. The content of the header can be arbitrary.

For example, provided in this folder:

`beclin1_108-128.fasta`

The file content is:

```
>beclin1_108-128
TMENLSRRLKVTGDLFDIMSG
```

#### models.csv

It is a CSV file which uses semicolon as a column delimiter which specifies the docking runs to be performed. For each line, all the run types defined in the config file will be performed (see below for more details).

The following information must be added, one line:

|Entry|Meaning|Example|
|---|---|---|
|`slim_name`|It is the protein name in which the SLiM is present|p62|
|`slim_seq`|It is the first-last sequence residue numbers of the SLiM, in the main isoform Uniprot sequence of the protein it was taken from|330-349|
|`apo_structure_source`|It is the PDB ID of the complex from which the apo structure under model was taken|2ZJD|
|`apo_chain_in_source`|chain name corresponding to the apo structure that is in `apo_structure_source`|a|
|`slim_chain`|chain name corresponding to the slim chain name in the original structure|b|
|`apo_seq`|the first-last sequence residue numbers corresponding to the residues in the structure of the apo protein, Uniprot main isoform numbering|1-120|
|`apo_model_name`|name of the model we are going to use for the apo, in case e.g. we needed to do some work on the `apo_structure_source` to reconstruct missing parts|model0|
|`apo_pdb`|name of the final pdb file corresponding to the apo model that will be used by CABS-dock|apo_lc3B_p62AB.B99990001.pdb|

N.B. The first line within the table must be: 
slim_name;slim_seq;apo_structure_source;apo_chain_in_source;apo_seq;apo_model_name;apo_pdb

The following lines can contain the information for the runs: 
`p62;330-349;2ZJD;a;1-120;model0;apo_lc3B_p62AB.B99990001.pdb`

In this example, we are considering the SLiM LIR of p62, residues 330-349; this will be docked using CABS-dock on the apo structure contained in apo_lc3B_p62AB.B99990001.pdb.
This apo structure is the model called "model0" that was derived starting from the protein complex with PDB ID 2ZJD, chain A, residues 1-120. 

#### Configuration file

A YAML file containing the script configuration. 

The following options and parameters must be set within the configuration file:

|Generic options|Meaning|
|---|---|
|`models_csv`|It is a file ";" separated containing all the input names, as described above|
|`apo_dir`|Path of the folder containing the apo structures|
|`slim_dir`|Path of the folder containing the peptide files in fasta format|
|`out_dir`|Path of the folder where the ouputs will be written|

|CABS-dock options|Meaning|
|---|---|
|`mc_runs`|Number of Monte Carlo cycles (>0)|
|`k-medoids`|Number of medoids in k-medoids clustering algorithm|
|`clustering-iterations`|Number of iterations of the clustering k-medoids algorithm|
|`saved_pdb`|which type of pdb output should be saved by CABSdock (default is "A" for all; see https://bitbucket.org/lcbio/cabsdock/wiki/Home#markdown-header--o-pdb-output-selection)|
|`dssp_location`|Path for the DSSP program|
|`verbose`|Controls how explicit the program output is. It ranges from 0 (only critical messages) to 4 (maximum verbosity)|
|`run_types`|this section controls the run types to be performed for each protein-SLiM combination specified in the models.csv file|

N.B., The restraints can be specified in the following way. If none of those are needed, just write `null`.

#### Specifying run types

A run type is a specific combination of CABSdock restraints and input secondary structure definition. One or more run type
must be specified in the config.yaml configuration file.

For each apo-SLiM combination (i.e. each line models.csv), all the defined run types are performed separately.

Run types can be specified a specific structure, for instance:

    run_types:
        blind:
            ss_def: null
            restraints: null
        D-R_D-N:
            ss_def: 'CCCCCCCCCCCCCCCCCCCC'
            restraints:
                - '--ca-rest-add 102:A 14:PEP 6.5 1.0'
                - '--ca-rest-add 99:A 14:PEP 5.0 1.0'

For each run type (in this example, "blind" and "D-R_D-N"), both a secondary structure definition and restraints can be defined.

Secondary structure definition (ss_def) can be either a string of letters, as specified by CABSdock, or null to indicate no secondary structure defined.

Restraints can either be null, if none need to be applied, or a list of command line options to define restraints. These are passed directly to the CABSdock command line.

### Outputs

Directories of typical CABS-dock outputs, one per run type, are expected for each line within the table.
The folders containing the output will be built and named with the information provided in the table.

For example, if a line appears like this:

`p62;330-349;2ZJD;a;1-120;model0;apo_lc3B_p62AB.B99990001.pdb`

the expected output will be located in the following path:

`p62/p62_2ZJDa_1-120_330-349/model0/blind`
`p62/p62_2ZJDa_1-120_330-349/model0/D_R-D_N`
...
 
### References

[^Mölder2021]: Mölder, F., Jablonski, K.P., Letcher, B., Hall, M.B., Tomkins-Tinch, C.H., Sochat, V., Forster, J., Lee, S., Twardziok, S.O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., Nahnsen, S., Köster, J., 2021. Sustainable data analysis with Snakemake. F1000Res 10, 33.

[^Kurcinski2019]: Mateusz Kurcinski, Maciej Pawel Ciemny, Tymoteusz Oleniecki, Aleksander Kuriata, Aleksandra E Badaczewska-Dawid, Andrzej Kolinski, Sebastian Kmiecik, CABS-dock standalone: a toolbox for flexible protein–peptide docking, Bioinformatics, Volume 35, Issue 20, 15 October 2019, Pages 4170–4172.

[^Webb2016]: Webb, B.; Sali, A. Comparative protein structure modeling using MODELLER. Curr. Protoc. Bioinforma.2016, 54, 5.6.1-5.6.37.

[^Kabsch1983]: Kabsch W, Sander C. Dictionary of protein secondary structure: pattern recognition of hydrogen-bonded and geometrical features. Biopolymers. 1983 Dec;22(12):2577-637.
