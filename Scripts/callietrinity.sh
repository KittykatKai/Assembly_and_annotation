#!/bin/bash
#SBATCH --job-name=trinity_assembly
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/flye_%j.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/flye_%j.err
#SBATCH --partition=pibu_el8
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch

set -euo pipefail
 
WORKDIR=/data/users/ksales/assembly_annotation_course
READS_DIR=$WORKDIR/RNAseq_Sha
OUTDIR=$WORKDIR/output_dir/trinity
THREADS=${SLURM_CPUS_PER_TASK:-16}
 
module purge
module load Trinity/2.15.1-foss-2021a
 
shopt -s nullglob
LEFT=("$READS_DIR"/*_1.fastq.gz "$READS_DIR"/*_1.fq.gz "$READS_DIR"/*_R1*.fastq.gz "$READS_DIR"/*_R1*.fq.gz)
RIGHT=("$READS_DIR"/*_2.fastq.gz "$READS_DIR"/*_2.fq.gz "$READS_DIR"/*_R2*.fastq.gz "$READS_DIR"/*_R2*.fq.gz)
shopt -u nullglob
 
if [[ ${#LEFT[@]} -eq 0 || ${#LEFT[@]} -ne ${#RIGHT[@]} ]]; then
    echo "ERROR: could not find matching paired read files in $READS_DIR" >&2
    ls -l "$READS_DIR"/ >&2
    exit 1
fi
 
LEFT_LIST=$(IFS=,; echo "${LEFT[*]}")
RIGHT_LIST=$(IFS=,; echo "${RIGHT[*]}")
 
mkdir -p "$(dirname "$OUTDIR")"
 
echo "Start: $(date)"
echo "Left:  $LEFT_LIST"
echo "Right: $RIGHT_LIST"
 
Trinity --seqType fq \
    --left "$LEFT_LIST" \
    --right "$RIGHT_LIST" \
    --CPU "$THREADS" \
    --max_memory 60G \
    --output "$OUTDIR"
 
echo "Finished: $(date)"