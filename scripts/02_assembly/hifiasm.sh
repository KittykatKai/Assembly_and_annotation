#!/bin/bash
#SBATCH --job-name=hifiasm
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Genome assembly of the Pyl-1 HiFi reads with Hifiasm, then GFA to FASTA conversion.
# Usage (from repo root): sbatch scripts/02_assembly/hifiasm.sh
# Output: output_dir/hifiasm/Pyl-1.bp.p_ctg.fa (primary contigs)

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

OUTDIR=$OUT_DIR/hifiasm
require_file "$HIFI_READS"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

apptainer exec --bind "$BIND" "$HIFIASM_SIF" hifiasm \
    -o "$OUTDIR/$ACCESSION" \
    -t "${SLURM_CPUS_PER_TASK:-16}" \
    "$HIFI_READS"

for GFA in "$OUTDIR"/*.p_ctg.gfa; do
    awk '/^S/{print ">"$2;print $3}' "$GFA" > "${GFA%.gfa}.fa"
done
