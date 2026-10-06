#!/bin/bash
#SBATCH --job-name=fastp_hifi
#SBATCH --time=02:10:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=4
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# fastp read statistics for the Pyl-1 HiFi reads (QC only; assemblies use the raw reads).
# Usage (from repo root): sbatch scripts/01_qc/fastp_hifi.sh

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

OUTDIR=$OUT_DIR/fastp
require_file "$HIFI_READS"
mkdir -p "$OUTDIR"

apptainer exec --bind "$BIND" "$FASTP_SIF" fastp \
    -i "$HIFI_READS" \
    -o "$OUTDIR/${HIFI_SAMPLE}_trimmed.fastq.gz" \
    -h "$OUTDIR/${HIFI_SAMPLE}_fastp.html" \
    -j "$OUTDIR/${HIFI_SAMPLE}_fastp.json" \
    --thread "${SLURM_CPUS_PER_TASK:-4}" \
    --detect_adapter_for_pe \
    --length_required 20 \
    --cut_front \
    --cut_tail \
    --cut_window_size 4 \
    --cut_mean_quality 20
