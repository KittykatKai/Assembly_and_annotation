#!/bin/bash
#SBATCH --job-name=nucmer_mummerplot
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pshort_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Whole genome alignments and dot plots: each assembly against TAIR10, and each pair of assemblies.
# Usage (from repo root): sbatch scripts/04_comparison/nucmer_mummerplot.sh
# Output: output_dir/nucmer/<comparison>.delta and <comparison>.png

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

OUTDIR=$OUT_DIR/nucmer
require_file "$REF_FASTA"
for A in "${GENOME_ASSEMBLERS[@]}"; do require_file "${ASSEMBLY[$A]}"; done
mkdir -p "$OUTDIR"
cd "$OUTDIR"

run_comparison () {
    local PREFIX=$1 R=$2 Q=$3
    apptainer exec --bind "$BIND" "$MUMMER_SIF" nucmer \
        --prefix "$PREFIX" \
        --breaklen 1000 \
        --mincluster 1000 \
        --threads "${SLURM_CPUS_PER_TASK:-16}" \
        "$R" "$Q"
    apptainer exec --bind "$BIND" "$MUMMER_SIF" mummerplot \
        -R "$R" -Q "$Q" \
        --filter -t png --large --layout --fat \
        -p "$PREFIX" \
        "$PREFIX.delta"
}

for A in "${GENOME_ASSEMBLERS[@]}"; do
    run_comparison "ref_vs_$A" "$REF_FASTA" "${ASSEMBLY[$A]}"
done
run_comparison flye_vs_hifiasm "${ASSEMBLY[flye]}"    "${ASSEMBLY[hifiasm]}"
run_comparison flye_vs_lja     "${ASSEMBLY[flye]}"    "${ASSEMBLY[lja]}"
run_comparison hifiasm_vs_lja  "${ASSEMBLY[hifiasm]}" "${ASSEMBLY[lja]}"
