#!/bin/bash
#SBATCH --job-name=quast_ref
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pshort_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# QUAST evaluation of the three genome assemblies against the TAIR10 reference and annotation.
# Usage (from repo root): sbatch scripts/03_evaluation/quast_ref.sh
# Output: output_dir/quast/with_reference/report.txt

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

OUTDIR=$OUT_DIR/quast/with_reference
require_file "$REF_FASTA"
require_file "$REF_GFF"
INPUTS=()
for A in "${GENOME_ASSEMBLERS[@]}"; do
    require_file "${ASSEMBLY[$A]}"
    INPUTS+=("${ASSEMBLY[$A]}")
done
mkdir -p "$OUTDIR"

apptainer exec --bind "$BIND" "$QUAST_SIF" quast.py \
    "${INPUTS[@]}" \
    --labels "$(IFS=,; echo "${GENOME_ASSEMBLERS[*]}")" \
    -r "$REF_FASTA" \
    --features "$REF_GFF" \
    --eukaryote \
    --threads "${SLURM_CPUS_PER_TASK:-16}" \
    -o "$OUTDIR"
