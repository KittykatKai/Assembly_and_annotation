#!/bin/bash
#SBATCH --job-name=fastp_rnaseq
#SBATCH --time=02:10:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=4
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Adapter and quality trimming of the paired end Sha RNA-seq reads.
# Usage (from repo root): sbatch scripts/01_qc/fastp_rnaseq.sh

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

OUTDIR=$OUT_DIR/fastp
R1=$RNASEQ_DIR/${RNASEQ_SAMPLE}_1.fastq.gz
R2=$RNASEQ_DIR/${RNASEQ_SAMPLE}_2.fastq.gz
require_file "$R1"
require_file "$R2"
mkdir -p "$OUTDIR"

apptainer exec --bind "$BIND" "$FASTP_SIF" fastp \
    -i "$R1" \
    -I "$R2" \
    -o "$OUTDIR/${RNASEQ_SAMPLE}_1_trimmed.fastq.gz" \
    -O "$OUTDIR/${RNASEQ_SAMPLE}_2_trimmed.fastq.gz" \
    -h "$OUTDIR/${RNASEQ_SAMPLE}_fastp.html" \
    -j "$OUTDIR/${RNASEQ_SAMPLE}_fastp.json" \
    --thread "${SLURM_CPUS_PER_TASK:-4}" \
    --detect_adapter_for_pe \
    --length_required 20 \
    --cut_front \
    --cut_tail \
    --cut_window_size 4 \
    --cut_mean_quality 20
