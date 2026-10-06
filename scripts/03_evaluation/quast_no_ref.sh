#!/bin/bash
#SBATCH --job-name=quast_no_ref
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# QUAST contiguity statistics for the three genome assemblies, without a reference.
# Usage (from repo root): sbatch scripts/03_evaluation/quast_no_ref.sh
# Output: output_dir/quast/no_reference/report.txt

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

OUTDIR=$OUT_DIR/quast/no_reference
INPUTS=()
for A in "${GENOME_ASSEMBLERS[@]}"; do
    require_file "${ASSEMBLY[$A]}"
    INPUTS+=("${ASSEMBLY[$A]}")
done
mkdir -p "$OUTDIR"

apptainer exec --bind "$BIND" "$QUAST_SIF" quast.py \
    "${INPUTS[@]}" \
    --labels "$(IFS=,; echo "${GENOME_ASSEMBLERS[*]}")" \
    --eukaryote \
    --est-ref-size "$GENOME_SIZE" \
    --threads "${SLURM_CPUS_PER_TASK:-16}" \
    -o "$OUTDIR"
