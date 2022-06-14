Readme for the example run. 

This example is run on three variants and the wildtype of 2XWR chain A. A structure covering the 
DNA binding domain of the protein p53. 

Here the three variants and a wild-type are present in the directory input_structures. 
The configuration file (pdb_input_dir variable) defines where the different directories, 
corresponding each to a different set of PDBs are stored. The name of the directory
containing the PDBs for each run is specified in the variant.csv file.

So for instance, for this case, in the config file we have:

pdb_input_dir: "."

and we have one run in the csv file:

source_structure,chain_in_source,aa_num_start,aa_num_end,source_type,pdb_dir
2XWR,A,91,289,xray,input_structures

meaning that our final pdb directory for this run will be `./input_structures'.

Furthermore, in the config file, we specify which structure file the coordinates
of the ligand ligand should be taken from. In this example, this is the 2XWR.pdb file.

