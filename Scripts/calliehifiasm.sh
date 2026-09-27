#!/bin/bash
#SBATCH --job-name=hifiasm_assembly
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/flye_%j.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/flye_%j.err
#SBATCH --partition=pibu_el8
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch
 
set -euo pipefail
 
CONTAINER=/containers/apptainer/hifiasm_0.25.0.sif
WORKDIR=/data/users/ksales/assembly_annotation_course
READS_DIR=$WORKDIR/Pyl-1
OUTDIR=$WORKDIR/output_dir/hifiasm
PREFIX=Pyl-1
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
echo "Reads: ${READS[*]}"
 
apptainer exec --bind /data "$CONTAINER" hifiasm -o "$OUTDIR/$PREFIX" -t "$THREADS" "${READS[@]}"
 
for GFA in "$OUTDIR"/*.p_ctg.gfa; do
    awk '/^S/{print ">"$2;print $3}' "$GFA" > "${GFA%.gfa}.fa"
    echo "Converted: ${GFA%.gfa}.fa"
done
 
echo "Finished: $(date)"
 