#!/bin/bash
#SBATCH --job-name=merqury_flye
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/merqury_flye_%j.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/merqury_flye_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --array=0-0
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch

export MERQURY="/usr/local/share/merqury"

CONTAINER=/containers/apptainer/merqury_1.3.sif
WORKDIR=/data/users/ksales/assembly_annotation_course
DB=$WORKDIR/output_dir/merqury/Pyl-1.meryl
ASSEMBLY=$WORKDIR/output_dir/flye/assembly.fasta
OUTDIR=$WORKDIR/output_dir/merqury/flye
NAME=flye

if [[ ! -d "$DB" ]]; then
    echo "ERROR: meryl database not found: $DB (run merqury_meryl_db.sh first)" >&2
    exit 1
fi

if [[ ! -s "$ASSEMBLY" ]]; then
    echo "ERROR: assembly not found or empty: $ASSEMBLY" >&2
    exit 1
fi

mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "Start: $(date)"
echo "Assembly: $ASSEMBLY"

apptainer exec --bind /data "$CONTAINER" sh "$MERQURY/merqury.sh" "$DB" "$ASSEMBLY" "$NAME"

echo "Finished: $(date)"
echo "QV:"
cat "$NAME".qv
echo "Completeness:"
cat "$NAME".completeness.stats
