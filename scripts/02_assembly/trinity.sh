#!/bin/bash
#SBATCH --job-name=trinity
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# De novo transcriptome assembly of the paired end Sha RNA-seq reads with Trinity.
# Usage (from repo root): sbatch scripts/02_assembly/trinity.sh
# Output: output_dir/trinity.Trinity.fasta (written next to the output folder)

set -euo pipefail
source "${SLURM_SUBMIT_DIR:-.}/config.sh"

module purge
module load "$TRINITY_MODULE"

OUTDIR=$OUT_DIR/trinity

shopt -s nullglob
LEFT=("$RNASEQ_DIR"/*_1.fastq.gz)
RIGHT=("$RNASEQ_DIR"/*_2.fastq.gz)
shopt -u nullglob

if [[ ${#LEFT[@]} -eq 0 || ${#LEFT[@]} -ne ${#RIGHT[@]} ]]; then
    echo "ERROR: no matching paired read files in $RNASEQ_DIR" >&2
    exit 1
fi
mkdir -p "$OUT_DIR"

Trinity --seqType fq \
    --left "$(IFS=,; echo "${LEFT[*]}")" \
    --right "$(IFS=,; echo "${RIGHT[*]}")" \
    --CPU "${SLURM_CPUS_PER_TASK:-16}" \
    --max_memory 60G \
    --output "$OUTDIR"
