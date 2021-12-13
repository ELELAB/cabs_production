# CABS-flex pipeline

## Overview

Structural Protein flexibility is difficult to study in an experimental setting, why simulations may increase our understanding of the structural conformations. This snakemake[^Mölder2021]-based pipeline [^Mölder2021] is designed to perform in-silico modeling of protein flexibility with CABSflex [^Kurcinski2019]. 

### CABSflex

CABSflex is a tool that creates fast simulations of protein structure flexibility based on simulations of protein dynamics using coarse grained protein models with optional reconstruction of all atom representations. CABSflex is computationally lighter than a classic all-atom MD which is the merit of its use. 

The input to CABSflex is, as a minimum, a PDB file of interest. Optionally a set of restrains and simulation parameters can be chosen. Once started, the CABS simulation runs the protein chain though one trajectory that creates 1000 models. These 1000 models are reduced to k clusters and each cluster is assigned a representative based on the medoids. The k representatives are reconstructed with an all-atom representation and k all atom models are the output 

## Requirements

The user must have `Snakemake` [^Mölder2021], `python` v3.7 or higher, `CABS-flex` [^Kurcinski2019], `Modeller` [^Webb2016] and `DSSP` [^Kabsch1983] installed.

The user will also need to provide:

- a PDB file or a directory of PDB files
- an appropriately formatted variants.csv and config.yaml file





## Usage

1. Clone this repository where you would like to run to the pipeline:

`git clone https://github.com/ELELAB/cabs_production/tree/master/cabsflex.git`
`cd cabsflex`

2. Edit the config.yaml and variants.csv files appropriately for your system.

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

#### variants.csv
It is a CSV file which uses semicolon as a column delimiter which specifies the structures that should undergo flexibility modeling. For each line, all the run types defined in the config file will be performed (see below for more details).

The following information must be added, one line:

|Entry|Meaning|Example|
|---|---|---|
|`source_sturcture`|The PDB id|2XWR|
|`chain_in_source`|It is the chain of interest in the source structure|A|
|`aa_num_start`|It is the numbering of the first amino acid in the structure|91|
|`aa_num_end`|It is the numbering of the last amino acid in the structure|289|
|`source_type`|The type of structure in question, e.g., X-ray, NMR or model|model|
|`pdb_dir`|the directory in which the structure can be found|2XWRa_91-289/test/|

N.B. The first line within the table must be: 
source_structure;chain_in_source;aa_num_start;aa_num_end;source_type;pdb_dir

The following lines can contain the information for the runs: 
`2XWR;A;91;289;model;2XWRa_91-289/test/`

In this example, we are considering chain A on the X-ray structure with pdb id 2XWR, which has undergone computational mutations. Each model of a mutation is avialable in `2XWRa_91-289/test/`

#### config.yaml
A YAML file containing the script configuration. 

The following options and parameters must be set within the configuration file:

|Generic options|Meaning|
|---|---|
|`variant_csv`|It is a file ";" separated containing all the input names, as described above|
|`pdb_dir`|Path of the directory containing the PDB structures|
|`out_dir`|Path of the folder where the ouputs will be written, per default is “./results”|


|CABS-flex options|Meaning|
|---|---|
|`k-medoids`|Number of medoids in k-medoids clustering algorithm|
|`dssp_location`|Path for the DSSP program|
|`verbose`|Controls how explicit the program output is. It ranges from 0 (only critical messages) to 4 (maximum verbosity)|
|`run_types`|this section controls the run types to be performed |

N.B., The restraints can be specified in the following way. If none of those are needed, just write `null`.

#### Specifying run types

A run type is a specific combination of CABSflex restraints and input secondary structure definition. One or more run type
must be specified in the config.yaml configuration file.

Run types can be specified a specific structure, for instance:

    run_types:
        Default:
            ss_def: null
            restraints: null
        metal_bound:
            ss_def: nulll
            restraints:
                - '--ca-rest-add'
                - '--sc-rest-add'

For each run type (in this example, “default and “metal_bound), both a secondary structure definition and restraints can be defined.

Secondary structure definition (ss_def) can be either a string of letters, as specified by CABSflex, or null to indicate no secondary structure defined.

Restraints can either be null, if none need to be applied, or a list of command line options to define restraints. These are passed directly to the CABSflex command line.

### Outputs

Directories of typical CABSflex outputs, one per run type, per model are expected for each line within the table, variants.csv.
The folders containing the output will be built and named with the information provided in the table.


### References

[^Mölder2021]: Mölder, F., Jablonski, K.P., Letcher, B., Hall, M.B., Tomkins-Tinch, C.H., Sochat, V., Forster, J., Lee, S., Twardziok, S.O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., Nahnsen, S., Köster, J., 2021. Sustainable data analysis with Snakemake. F1000Res 10, 33.

[^Kurcinski2019]: Mateusz Kurcinski, Tymoteusz Oleniecki, Maciej Pawel Ciemny, Aleksander Kuriata, Andrzej Kolinski, Sebastian Kmiecik, CABS-flex standalone: a simulation environment for fast modeling of protein flexibility, Bioinformatics, Volume 35, Issue 4, 15 February 2019, Pages 694–695, https://doi.org/10.1093/bioinformatics/bty685

[^Webb2016]: Webb, B.; Sali, A. Comparative protein structure modeling using MODELLER. Curr. Protoc. Bioinforma.2016, 54, 5.6.1-5.6.37.

[^Kabsch1983]: Kabsch W, Sander C. Dictionary of protein secondary structure: pattern recognition of hydrogen-bonded and geometrical features. Biopolymers. 1983 Dec;22(12):2577-637.
