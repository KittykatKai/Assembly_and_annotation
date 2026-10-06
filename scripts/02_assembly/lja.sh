#!/bin/bash
#SBATCH --job-name=lja
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Genome assembly of the Pyl-1 HiFi reads with LJA (multiplex de Bruijn graph).
# Usage (from repo root): sbatch scripts/02_assembly/lja.sh
# Output: output_dir/lja/assembly.fasta

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

OUTDIR=$OUT_DIR/lja
require_file "$HIFI_READS"
mkdir -p "$OUT_DIR"

apptainer exec --bind "$BIND" "$LJA_SIF" lja \
    -o "$OUTDIR" \
    -t "${SLURM_CPUS_PER_TASK:-16}" \
    --reads "$HIFI_READS"
