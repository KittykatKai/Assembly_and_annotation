#!/bin/bash
#SBATCH --job-name=kmer_jellyfish
#SBATCH --time=04:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=4
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/kmer_jellyfish_%j.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/kmer_jellyfish_%j.err

# Count canonical 21-mers in the Pyl-1 HiFi reads and build a histogram for GenomeScope.
# Usage: sbatch kmer_jellyfish.sh
# Output: /data/users/ksales/assembly_annotation_course/output_dir/kmer/Pyl-1_k21.histo

set -euo pipefail

READS=/data/courses/assembly-annotation-course/raw_data/Pyl-1/ERR11437347.fastq.gz
OUTDIR=/data/users/ksales/assembly_annotation_course/output_dir/kmer
SIF_DIR=/containers/apptainer
K=21
THREADS=${SLURM_CPUS_PER_TASK:-4}
JELLYFISH_SIF=${JELLYFISH_SIF:-$(ls "$SIF_DIR"/*ellyfish*.sif 2>/dev/null | head -n1)}

if [[ -z "$JELLYFISH_SIF" ]]; then
    echo "ERROR: no Jellyfish container found in $SIF_DIR" >&2
    exit 1
fi
if [[ ! -s "$READS" ]]; then
    echo "ERROR: reads not found: $READS" >&2
    exit 1
fi
echo "Jellyfish container: $JELLYFISH_SIF"

mkdir -p "$OUTDIR"

zcat "$READS" | apptainer exec --bind /data "$JELLYFISH_SIF" jellyfish count \
    -C -m "$K" -s 5G -t "$THREADS" \
    -o "$OUTDIR/Pyl-1_k${K}.jf" \
    /dev/stdin

apptainer exec --bind /data "$JELLYFISH_SIF" jellyfish histo \
    -t "$THREADS" \
    "$OUTDIR/Pyl-1_k${K}.jf" > "$OUTDIR/Pyl-1_k${K}.histo"

rm "$OUTDIR/Pyl-1_k${K}.jf"
echo "Histogram: $OUTDIR/Pyl-1_k${K}.histo"