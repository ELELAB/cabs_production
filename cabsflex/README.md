# CABS-flex pipeline

## Overview

This snakemake[^Mölder2021]-based pipeline [^Mölder2021] is designed to perform in-silico modeling of protein flexibility with CABSflex [^Kurcinski2019]. 
In particular, it is designed to run CABSflex on a set of structural variants of a given protein, each one stored in a separate PDB file.

### CABSflex

CABSflex is a tool that creates fast simulations of protein structure flexibility based on simulations of protein dynamics using coarse-grained protein models with an optional reconstruction of all-atom representations. CABSflex is computationally lighter than a classic all-atom MD which is the merit of its use. 

The input to the CABSflex tool is, as a minimum, a PDB file of interest. Optionally a set of restraints and simulation parameters can be chosen. Once started, the CABS simulation runs the protein chain through one trajectory that creates 1000 models. These 1000 models are reduced to k clusters and each cluster is assigned a representative based on the medoids. The k representatives have been reconstructed with an all-atom representation and k all-atom models are the output. 

The input to this CABSflex pipeline is a comma-separated file, variants.csv, containing information on one or more directories containing PDB files. The content of this file is described below in the design of the input files section. Additionally, a configuration file and the snake file itself are required. 

## Requirements

The user must have `Snakemake` [^Mölder2021], `python` v3.7 or higher, `CABS-flex` [^Kurcinski2019], `Modeller` [^Webb2016] and `DSSP` [^Kabsch1983] installed.

The user will also need to provide:

- A directory containing one or more PDB files. PDB files should be named as follows:

`{identifier}_{chain}_{WT residue type}{residue number}{variant residue type}.pdb`

so for instance:

`2XWRa_A_ALA129ASP.pdb`

the corresponding wild-type structure is also identified and used as:

`{identifier}_{chain}_WT.pdb`

- An appropriately formatted variants.csv and config.yaml file (see below)


## Usage

1. Clone this repository where you would like to run to the pipeline:

`git clone https://github.com/ELELAB/cabs_production.git`
`cd cabs_production/cabsflex`

2. Edit the config.yaml and variants.csv files appropriately for your system.

3. run snakemake:

`snakemake --cores NCORES`


### Options

Some widely-used snakemake options that might come useful:

|Option  |Meaning  |
|---|---|
|`--cores`  |Number of cores to be used|
|`-p`    |Print out all actions that are being performed|
|`--dry-run` |Generate DAG but don't run rules - for testing purposes|



### Design of input files

#### snakefile

It is the file that contains all the instructions to be executed. Usually, it doesn't need to be changed.

#### variants.csv
It is a CSV file that uses a comma as a column delimiter which specifies the structures that should undergo flexibility modeling. Each line specifies a set of mutants (i.e. a set of PDB files). For each line, all the run types defined in the config file will be performed (see below for more details).

The following information must be added:

|Column name|Meaning|Example|
|---|---|---|
|`source_structure`|The identifier of the original structure, in this case PDB ID and original chain identifier|2XWRa|
|`chain_in_source`|It is the chain of interest in the source structure|A|
|`aa_num_start`|It is the numbering of the first amino acid in the structure|91|
|`aa_num_end`|It is the numbering of the last amino acid in the structure|289|
|`source_type`|The type of structure in question, e.g., X-ray, NMR or model|model|
|`pdb_dir`|the directory in which the structure can be found. This path starts from the `pdb_dir` directory specified in the config file|2XWRa_91-289/test/|

Example:
source_structure,chain_in_source,aa_num_start,aa_num_end;source_type,pdb_dir
2XWRa,A,91,289,model,2XWRa_91-289/test/

 N.B. The header line within the table must be kept.

In this example, we are considering chain A on the X-ray structure with PDB id 2XWR, which has undergone computational mutations. Each model of a mutation is available in `2XWRa_91-289/test/`

#### config.yaml
A YAML file containing the script configuration. 

The following options and parameters must be set within the configuration file:

|Generic options|Meaning|
|---|---|
|`variant_csv`|It is a file “,” separated containing all the input names, as described above|
|`pdb_dir`|Path of the directory containing the PDB structures|
|`out_dir`|Path of the folder where the outputs will be written, per default is “./results”|

|CABS-flex options|Meaning|
|---|---|
|`k-medoids`|Number of medoids in k-medoids clustering algorithm|
|`dssp_location`|Path for the DSSP program|
|`verbose`|Controls how explicit the program output is. It ranges from 0 (only critical messages) to 4 (maximum verbosity)|
|`run_types`|this section controls the run types to be performed |
|`mc-cycles`| This option,(-y, --mc-cycles NUM) sets the number of Monte Carlo cycles to NUM (NUM>0, default value = 50).|
|`mc-steps`| This option, (-s, --mc-steps NUM) sets number of Monte Carlo cycles between trajectory frames to NUM (NUM > 0, default value = 50). |
|`mc-annealing`| This option, (-a, --mc-annealing NUM) sets number of Monte Carlo temperature annealing cycles to NUM (NUM > 0, default value = 20, changing default value is recommended only for advanced users). |
|`rebuild-models`| Rebuild final models to all-atom representation (requires MODELLER installed), the default value is true |
|`Random Seed`| Setting a random seed for the run. As a default all random seeds are set to 10, which ensures reproducibility of runs. |

N.B., The restraints can be specified in the following way. If none of those are needed, just write `null`.

#### Specifying run types

A run type is a specific combination of CABSflex restraints and input secondary structure definition. One or more runtypes
must be specified in the config.yaml configuration file.

Run types can be specified a specific structure, for instance:

  run_types:
    Default:
      ss_def: null
      restraints: null
    metal_bound:
      ss_def: null
      restraints: 
        - '--ca-rest-add 179:A 176:A 5.5 1.0'
        - '--ca-rest-add 179:A 238:A 6.6 1.0'
        - '--ca-rest-add 179:A 242:A 8.1 1.0'
        - '--ca-rest-add 176:A 238:A 7.1 1.0'
        - '--ca-rest-add 176:A 242:A 6.5 1.0'
        - '--ca-rest-add 238:A 242:A 6.7 1.0'

For each run type (in this example, “default and “metal_bound), both a secondary structure definition and restraints can be defined.

Secondary structure definition (ss_def) can be either a string of letters, as specified by CABSflex, or null to indicate no secondary structure defined.

Restraints can either be null if none need to be applied, or a list of command-line options to define restraints. These are passed directly to the CABSflex command line.

### Outputs

Directories of typical CABSflex outputs, one per run type, per model are expected for each line within the table, variants.csv.
The folders containing the output will be built and named with the information provided in the table.

Example:

[source_structure]_[chain_in_source]_[aa_num_start]-[aa_num_end]_[WT_amino_acid][AA_num][Mutated_amino_acid]

	2XWRa_A_91-289_A129D
 		- model
			- default
				- 2XWRa_A_ALA129ASP.pdb
				- CABS.log
				- config.ini
				- input.pdb -> 2XWRa_A_ALA129ASP.pdb
				- output_data
				- output_pdbs
					- model_0.pdb
					- model_1.pdb
					- …
					- model_n.pdb
					- cluster_0.pdb
					- cluster_1.pdb
					- …
					- cluster_n.pdb
				- plots
				- README.txt
				- run.sh
			- metal_bound
				- 2XWRa_A_ALA129ASP.pdb
				- CABS.log
				- config.ini
				- input.pdb -> 2XWRa_A_ALA129ASP.pdb
				- output_data
				- output_pdbs
					- model_0.pdb
					- model_1.pdb
					- …
					- model_n.pdb
					- cluster_0.pdb
					- cluster_1.pdb
					- …
					- cluster_n.pdb
				- plots
				- README.txt
				- run.sh
	2XWRa_A_91-289_A129E
		- model
			- default
			- metal_bound
	2XWRa_A_91-289_A129S
		- model
			- default
			- metal_bound

Notice that there is only "model" in this example, however, experimental inputs are also applicable defined by the method, e.g., xray.

### References

[^Mölder2021]: Mölder, F., Jablonski, K.P., Letcher, B., Hall, M.B., Tomkins-Tinch, C.H., Sochat, V., Forster, J., Lee, S., Twardziok, S.O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., Nahnsen, S., Köster, J., 2021. Sustainable data analysis with Snakemake. F1000Res 10, 33.

[^Kurcinski2019]: Mateusz Kurcinski, Tymoteusz Oleniecki, Maciej Pawel Ciemny, Aleksander Kuriata, Andrzej Kolinski, Sebastian Kmiecik, CABS-flex standalone: a simulation environment for fast modeling of protein flexibility, Bioinformatics, Volume 35, Issue 4, 15 February 2019, Pages 694–695, https://doi.org/10.1093/bioinformatics/bty685

[^Webb2016]: Webb, B.; Sali, A. Comparative protein structure modeling using MODELLER. Curr. Protoc. Bioinforma.2016, 54, 5.6.1-5.6.37.

[^Kabsch1983]: Kabsch W, Sander C. Dictionary of protein secondary structure: pattern recognition of hydrogen-bonded and geometrical features. Biopolymers. 1983 Dec;22(12):2577-637.
