#!/bin/bash
#SBATCH --job-name=merqury_meryldb
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/merqury_meryldb_%j.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/merqury_meryldb_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --array=0-0
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch


set -euo pipefail

export MERQURY="/usr/local/share/merqury"

CONTAINER=/containers/apptainer/merqury_1.3.sif
WORKDIR=/data/users/ksales/assembly_annotation_course
READS_DIR=$WORKDIR/Pyl-1
OUTDIR=$WORKDIR/output_dir/merqury
DB=$OUTDIR/Pyl-1.meryl
K=31
GENOME_SIZE=135000000
THREADS=${SLURM_CPUS_PER_TASK:-16}

shopt -s nullglob
READS=("$READS_DIR"/*.fastq.gz "$READS_DIR"/*.fq.gz "$READS_DIR"/*.fastq "$READS_DIR"/*.fq)
shopt -u nullglob

if [[ ${#READS[@]} -eq 0 ]]; then
    echo "ERROR: no read files found in $READS_DIR" >&2
    exit 1
fi

mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "Start: $(date)"
echo "best_k.sh estimate for a ${GENOME_SIZE} bp genome:"
apptainer exec --bind /data "$CONTAINER" sh "$MERQURY/best_k.sh" "$GENOME_SIZE"
echo "Using k=$K"

rm -rf "$DB"
apptainer exec --bind /data "$CONTAINER" meryl k="$K" count threads="$THREADS" memory=60g "${READS[@]}" output "$DB"

echo "Finished: $(date)"

