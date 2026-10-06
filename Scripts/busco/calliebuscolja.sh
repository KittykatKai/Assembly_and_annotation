#!/bin/bash
#SBATCH --job-name=busco_lja
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/busco_lja_%j.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/busco_lja_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --array=0-0
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch

set -euo pipefail

CONTAINER=/containers/apptainer/busco_5.7.1.sif
WORKDIR=/data/users/ksales/assembly_annotation_course
INPUT=$WORKDIR/output_dir/lja/assembly.fasta
OUTDIR=$WORKDIR/output_dir/busco
DOWNLOADS=$OUTDIR/busco_downloads
NAME=lja
LINEAGE=brassicales_odb10
THREADS=${SLURM_CPUS_PER_TASK:-16}

if [[ ! -s "$INPUT" ]]; then
    echo "ERROR: assembly not found or empty: $INPUT" >&2
    exit 1
fi

mkdir -p "$OUTDIR"

echo "Start: $(date)"
echo "Input: $INPUT"

apptainer exec --bind /data "$CONTAINER" busco \
    -i "$INPUT" \
    -m genome \
    -l "$LINEAGE" \
    -o "$NAME" \
    --out_path "$OUTDIR" \
    --download_path "$DOWNLOADS" \
    -c "$THREADS" \
    -f

echo "Finished: $(date)"
echo "Lineage used:"
grep -i "lineage dataset" "$OUTDIR/$NAME"/short_summary*.txt
cat "$OUTDIR/$NAME"/short_summary*.txt
