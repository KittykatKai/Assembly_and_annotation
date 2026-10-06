#!/bin/bash
#SBATCH --job-name=flye
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Genome assembly of the Pyl-1 HiFi reads with Flye (repeat graph).
# Usage (from repo root): sbatch scripts/02_assembly/flye.sh
# Output: output_dir/flye/assembly.fasta

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

OUTDIR=$OUT_DIR/flye
require_file "$HIFI_READS"
mkdir -p "$OUT_DIR"

FLYE_ARGS=(--pacbio-hifi "$HIFI_READS" --out-dir "$OUTDIR" --threads "${SLURM_CPUS_PER_TASK:-16}")
[[ -f "$OUTDIR/params.json" ]] && FLYE_ARGS+=(--resume)

apptainer exec --bind "$BIND" "$FLYE_SIF" flye "${FLYE_ARGS[@]}"
