# CABS-dock pipline

## Overview

The CABS-dock pipeline is a snakemake-based rigorous method [^Mölder2021] for protein-peptide docking which uses CABS-dock [^Kurcinski2019] for the poses generation.

## Background

### Protein-peptide docking

The protein-peptide docking is a procedure which consists in the search for near-native peptide conformations and orientations (docking poses) with respect to a target protein, where at least the structure of the target protein is known. Scoring functions are then used to rank the docking poses and assess the quality of the predicted complexes. 

In general, the conformational space that both the peptide and the target protein can assume is huge. Then, a reduced representation is employed to speed up the process. 

### CABS-dock

CABS-dock [^Kurcinski2019] is an efficient and fast multiscale modeling procedure based on CABS model (a coarse-grained model representation). Each amino acid is represented by up to four interaction centers, simulation dynamics are controlled by the Monte Carlo scheme, and the force field is based on statistical potentials.

### Snakemake

Snakemake [^Mölder2021] is a python-based tool useful to create reproducible and scalable pipelines for data analyses. It is ideal for cases in which both reproducibility and generalizability of the same study and its application to several case studies are important.

## Requiremets

The user must have `Snakemake` [^Mölder2021] and `python` v3.7 or higher installed, togheter with `Modeller` [^Webb2016] and `DSSP` [^Kabsch1983] softwares.

## Usage

### Command line

`snakemake [--cores NCORES]`

### Options

|Option   |Meaning   |
|---|---|
|`--cores`   |Number of cores to be used   |


### Input files

#### snakefile

It is the file that contains all the instructions to be executed. 

#### Apo structures

The apo structure is, by definition, the structure of the receptor protein in an unbound state with respect the interacting peptide. All the structures needed for the docking procedure must be collected in a folder whose path is specified within the configuration file. 

The apo structures must be provided in PDB format. 

#### Peptides

The peptides are provided as strings in FASTA format. One file for each peptide is required and they must be located in a folder. Each file name must be stored with the following name structure:

`[name of the peptide]_[first-last sequence residue numbers of the FASTA sequence].fasta`

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
|`lir_dir`|Path of the folder containing the peptide files in fasta format|
|`out_dir`|Path of the folder where the ouputs will be written|

|CABS-dock options|Meaning|
|---|---|
|`mc_runs`|Number of Monte Carlo cycles (NUM>0)|
|`k-medoids`|Number of medoids in k-medoids clustering algorithm|
|`clustering-iterations`|Number of iterations of the clustering k-medoids algorithm|
|`saved_pdb`|Select structures to be saved in the pdb format|
|`dssp_location`|Path for the DSSP program|
|`verbose`|Controls how explicit the program output is. It ranges from 0 (only critical messages) to 4 (maximum verbosity)|

N.B. The `lir_dir` name depends on the fact that this protocol was built for the docking of proteins containing LC3 interacting region (LIRs).

### Outputs

The typical CABS-dock outputs are expected for each line within the table. The folders containing the output will be built and named with the information provided in the table.

For example, if a line appears like this:

`p62;lc3b;1-120;330-349;blind;2ZJD;a;apo_lc3B_p62AB.B99990001.pdb`

the expected output will be located in the following path:

`lc3b/lir_complexes/p62/p62_2ZJDa_1-120_330-349/blind/`

N.B. The lir_complexes folder will be created since this protocol was built for the docking of proteins containing LC3 interacting region (LIRs). This can be easily changed within the snakefile by adapting the folder name to the peptides under study.

 
### References

[^Mölder2021]: Mölder, F., Jablonski, K.P., Letcher, B., Hall, M.B., Tomkins-Tinch, C.H., Sochat, V., Forster, J., Lee, S., Twardziok, S.O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., Nahnsen, S., Köster, J., 2021. Sustainable data analysis with Snakemake. F1000Res 10, 33.

[^Kurcinski2019]: Mateusz Kurcinski, Maciej Pawel Ciemny, Tymoteusz Oleniecki, Aleksander Kuriata, Aleksandra E Badaczewska-Dawid, Andrzej Kolinski, Sebastian Kmiecik, CABS-dock standalone: a toolbox for flexible protein–peptide docking, Bioinformatics, Volume 35, Issue 20, 15 October 2019, Pages 4170–4172.

[^Webb2016]: Webb, B.; Sali, A. Comparative protein structure modeling using MODELLER. Curr. Protoc. Bioinforma.2016, 54, 5.6.1-5.6.37.

[^Kabsch] : Kabsch W, Sander C. Dictionary of protein secondary structure: pattern recognition of hydrogen-bonded and geometrical features. Biopolymers. 1983 Dec;22(12):2577-637.
