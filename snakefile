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
                expand("%s/{template}/lir_complexes/{peptide_name}/{peptide_name}_{pdb_file}{chain}_{aa_protein}_{aa_peptide}/{run_type}/output_pdbs/model_{n}.pdb" % config['out_dir'],
                    zip,
                    template=models['template'],
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
        lir=os.path.join(config['lir_dir'], "{peptide_name}_{aa_peptide}.fasta")

    params:
        ss = get_ss,
        restraints = get_restraints

    output:
        expand("%s/{template}/lir_complexes/{peptide_name}/{peptide_name}_{pdb_file}{chain}_{aa_protein}_{aa_peptide}/{run_type}/output_pdbs/model_{n}.pdb" % config['out_dir'], 
               n=np.arange(config['cabsdock']['k-medoids']),
               allow_missing=True)
    shell:
        """
        working_dir={config[out_dir]}/{wildcards.template}/lir_complexes/{wildcards.peptide_name}/{wildcards.peptide_name}_{wildcards.pdb_file}{wildcards.chain}_{wildcards.aa_protein}_{wildcards.aa_peptide}/{wildcards.run_type}
        cp {input.apo} $working_dir/
        cp {input.lir} $working_dir/
        cp config.yaml $working_dir/
        CABSdock\
                -i {input.apo}\
                -p $(tail -n 1 {input.lir}){params.ss}\
                -y {config[cabsdock][mc_runs]}\
                -k {config[cabsdock][k-medoids]}\
                --clustering-iterations {config[cabsdock][clustering-iterations]}\
                {params.restraints}\
                -A\
                -o {config[cabsdock][saved_pdb]}\
                -v {config[cabsdock][verbose]}\
                --dssp-command {config[cabsdock][dssp_location]}\
                -w $working_dir/
       """
