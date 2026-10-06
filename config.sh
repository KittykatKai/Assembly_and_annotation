#!/bin/bash
# Central configuration for the Pyl-1 assembly project.
# Every script sources this file, so to reproduce the analysis elsewhere
# only the paths below need changing.

# Project folders (defaults to the directory jobs are submitted from)
PROJECT_DIR="${SLURM_SUBMIT_DIR:-$(pwd)}"
OUT_DIR="$PROJECT_DIR/output_dir"

# Input data (IBU cluster, course data)
RAW_DATA=/data/courses/assembly-annotation-course/raw_data
HIFI_DIR=$RAW_DATA/Pyl-1
HIFI_SAMPLE=ERR11437347
HIFI_READS=$HIFI_DIR/${HIFI_SAMPLE}.fastq.gz
RNASEQ_DIR=$RAW_DATA/RNAseq_Sha
RNASEQ_SAMPLE=ERR754081

# Reference genome and annotation (Ensembl TAIR10, release 57)
REF_DIR=/data/courses/assembly-annotation-course/references
REF_FASTA=$REF_DIR/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
REF_GFF=$REF_DIR/Arabidopsis_thaliana.TAIR10.57.gff3

# Analysis parameters
ACCESSION=Pyl-1
GENOME_SIZE=135000000
BUSCO_LINEAGE=brassicales_odb10
MERYL_K=31

# Software (Apptainer containers and modules)
BIND=/data
SIF_DIR=/containers/apptainer
FASTQC_SIF=$SIF_DIR/fastqc-0.12.1.sif
FASTP_SIF=$SIF_DIR/fastp_0.24.1.sif
FLYE_SIF=$SIF_DIR/flye_2.9.5.sif
HIFIASM_SIF=$SIF_DIR/hifiasm_0.25.0.sif
LJA_SIF=$SIF_DIR/lja-0.2.sif
BUSCO_SIF=$SIF_DIR/busco_5.7.1.sif
QUAST_SIF=$SIF_DIR/quast_5.2.0.sif
MERQURY_SIF=$SIF_DIR/merqury_1.3.sif
MUMMER_SIF=$SIF_DIR/mummer4_gnuplot.sif
TRINITY_MODULE=Trinity/2.15.1-foss-2021a

# Final assemblies, used by the evaluation and comparison steps
declare -A ASSEMBLY=(
    [flye]=$OUT_DIR/flye/assembly.fasta
    [hifiasm]=$OUT_DIR/hifiasm/${ACCESSION}.bp.p_ctg.fa
    [lja]=$OUT_DIR/lja/assembly.fasta
    [trinity]=$OUT_DIR/trinity.Trinity.fasta
)
GENOME_ASSEMBLERS=(flye hifiasm lja)

# Stop with a clear message if a required file is missing
require_file () {
    if [[ ! -s "$1" ]]; then
        echo "ERROR: required file not found or empty: $1" >&2
        exit 1
    fi
}
