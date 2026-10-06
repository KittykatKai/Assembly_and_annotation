#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --time=02:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Quality report for the Pyl-1 PacBio HiFi reads.
# Usage (from repo root): sbatch scripts/01_qc/fastqc.sh

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

OUTDIR=$OUT_DIR/fastqc
require_file "$HIFI_READS"
mkdir -p "$OUTDIR"

apptainer exec --bind "$BIND" "$FASTQC_SIF" fastqc \
    "$HIFI_READS" \
    -o "$OUTDIR" \
    -t "${SLURM_CPUS_PER_TASK:-1}"
