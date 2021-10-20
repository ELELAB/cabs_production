import pandas as pd
import numpy as np
import os

configfile: 'config.yaml'

models = pd.read_csv(config['models_file.csv'], sep=';')

def get_ss(wildcards):

    this_ss_def = config['cabsdock']['run_types'][wildcards.run_type]['ss_def']

    if this_ss_def is None:
        return ""
    else:
        return f":{this_ss_def}"

def get_restraints(wildcards):

    this_restr = config['cabsdock']['run_types'][wildcards.run_type]['restraints']

    if this_restr is None:
        return ""
    else:
        return " ".join(this_restr)

rule all:
    input:
        expand(
            expand(
                expand("%s/{peptide_name}/{peptide_name}_{pdb_file}{chain}_{aa_protein}_{aa_peptide}/{run_type}/output_pdbs/model_{n}.pdb" % config['out_dir'],
                    zip,
                    peptide_name=models['peptide_name'],
                    pdb_file=models['pdb_file'],
                    chain=models['chain'],
                    aa_protein=models['aa_protein'],
                    aa_peptide=models['aa_peptide'], 
                    allow_missing=True),
                run_type=list(config['cabsdock']['run_types'].keys()),
                allow_missing=True),
            n=np.arange(config['cabsdock']['k-medoids']))

rule cabs_run:
    input:
        apo=lambda wildcards: os.path.join(config['apo_dir'], models[(models['pdb_file'] == wildcards.pdb_file) & (models['peptide_name'] == wildcards.peptide_name)]['model'].to_list()[0]),
        slim=os.path.join(config['slim_dir'], "{peptide_name}_{aa_peptide}.fasta")

    params:
        ss = get_ss,
        restraints = get_restraints

    output:
        expand("%s/{peptide_name}/{peptide_name}_{pdb_file}{chain}_{aa_protein}_{aa_peptide}/{run_type}/output_pdbs/model_{n}.pdb" % config['out_dir'],
               n=np.arange(config['cabsdock']['k-medoids']),
               allow_missing=True)
    shell:
        """
        working_dir={config[out_dir]}/{wildcards.peptide_name}/{wildcards.peptide_name}_{wildcards.pdb_file}{wildcards.chain}_{wildcards.aa_protein}_{wildcards.aa_peptide}/{wildcards.run_type}

        cp {input.apo} $working_dir/
        cp {input.slim} $working_dir/

        cd $working_dir

        cat <<EOF > README
This directory contains a CABS-dock run to model the structure of a complex
between a SLIM peptide and a protein:

    apo structure: {wildcards.pdb_file}, chain {wildcards.chain}, {wildcards.aa_protein}
    slim fasta: {wildcards.peptide_name}, {wildcards.aa_peptide}
    run type: {wildcards.run_type}

This has been performed by running the
run.sh script:

    bash run.sh

a log file called "CABS.log" contaning the output of CABS-dock has also
been written.
EOF

        cat <<"EOF" > run.sh
export slim_seq=$(tail -n 1 $(basename {input.apo}))
export apo_file=$(basename {input.apo})

CABSdock\\
    -i $apo_file\\
    -p $(tail -n 1 $slim_file){params.ss}\\
    -y {config[cabsdock][mc_runs]}\\
    -k {config[cabsdock][k-medoids]}\\
    --clustering-iterations {config[cabsdock][clustering-iterations]}\\
    {params.restraints}\\
    -A\\
    -o {config[cabsdock][saved_pdb]}\\
    -v {config[cabsdock][verbose]}\\
    --dssp-command {config[cabsdock][dssp_location]}\\
    --log
EOF

        bash run.sh
        """
