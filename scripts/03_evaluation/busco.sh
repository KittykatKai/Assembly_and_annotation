#!/bin/bash
#SBATCH --job-name=busco
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# BUSCO completeness for one assembly (genome mode, or transcriptome mode for Trinity).
# Usage (from repo root): sbatch --job-name=busco_flye scripts/03_evaluation/busco.sh flye
#   assembler: flye | hifiasm | lja | trinity
# Output: output_dir/busco/<assembler>/short_summary*.txt

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

NAME=${1:?usage: busco.sh <flye|hifiasm|lja|trinity>}
INPUT=${ASSEMBLY[$NAME]:?unknown assembler: $NAME}
MODE=genome
[[ "$NAME" == trinity ]] && MODE=transcriptome

OUTDIR=$OUT_DIR/busco
require_file "$INPUT"
mkdir -p "$OUTDIR"

apptainer exec --bind "$BIND" "$BUSCO_SIF" busco \
    -i "$INPUT" \
    -m "$MODE" \
    -l "$BUSCO_LINEAGE" \
    -o "$NAME" \
    --out_path "$OUTDIR" \
    --download_path "$OUTDIR/busco_downloads" \
    -c "${SLURM_CPUS_PER_TASK:-16}" \
    -f

grep -i "lineage dataset" "$OUTDIR/$NAME"/short_summary*.txt
