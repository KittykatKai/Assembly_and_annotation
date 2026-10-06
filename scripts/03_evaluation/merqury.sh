#!/bin/bash
#SBATCH --job-name=merqury
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Merqury QV and k-mer completeness for one genome assembly (needs meryl_db.sh first).
# Usage (from repo root): sbatch --job-name=merqury_flye scripts/03_evaluation/merqury.sh flye
#   assembler: flye | hifiasm | lja
# Output: output_dir/merqury/<assembler>/<assembler>.qv, .completeness.stats, spectra plots

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"
export MERQURY=/usr/local/share/merqury

NAME=${1:?usage: merqury.sh <flye|hifiasm|lja>}
INPUT=${ASSEMBLY[$NAME]:?unknown assembler: $NAME}
DB=$OUT_DIR/merqury/${ACCESSION}.meryl
OUTDIR=$OUT_DIR/merqury/$NAME

[[ -d "$DB" ]] || { echo "ERROR: meryl database not found: $DB" >&2; exit 1; }
require_file "$INPUT"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

apptainer exec --bind "$BIND" "$MERQURY_SIF" sh "$MERQURY/merqury.sh" "$DB" "$INPUT" "$NAME"

cat "$NAME.qv" "$NAME.completeness.stats"
