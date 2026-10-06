#!/bin/bash
#SBATCH --job-name=meryl_db
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Build the k-mer database from the Pyl-1 HiFi reads, shared by all Merqury runs.
# Usage (from repo root): sbatch scripts/03_evaluation/meryl_db.sh
# Output: output_dir/merqury/Pyl-1.meryl

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"
export MERQURY=/usr/local/share/merqury

OUTDIR=$OUT_DIR/merqury
DB=$OUTDIR/${ACCESSION}.meryl
require_file "$HIFI_READS"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "best_k.sh estimate for a ${GENOME_SIZE} bp genome (k used: $MERYL_K):"
apptainer exec --bind "$BIND" "$MERQURY_SIF" sh "$MERQURY/best_k.sh" "$GENOME_SIZE"

rm -rf "$DB"
apptainer exec --bind "$BIND" "$MERQURY_SIF" meryl \
    k="$MERYL_K" count threads="${SLURM_CPUS_PER_TASK:-16}" memory=60g \
    "$HIFI_READS" output "$DB"
