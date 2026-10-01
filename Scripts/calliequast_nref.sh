#!/bin/bash
#SBATCH --job-name=Quast_ref
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/quast_ef_%j.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/quast_ref_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --array=0-0
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch


set -euo pipefail
 
CONTAINER=/containers/apptainer/quast_5.2.0.sif
WORKDIR=/data/users/ksales/assembly_annotation_course
OUTDIR=$WORKDIR/output_dir/quast/no_reference
THREADS=${SLURM_CPUS_PER_TASK:-16}
EST_SIZE=135000000
 
ASSEMBLIES=(
    "$WORKDIR/output_dir/flye/assembly.fasta"
    "$WORKDIR/output_dir/hifiasm/Pyl-1.bp.p_ctg.fa"
    "$WORKDIR/output_dir/lja/assembly.fasta"
)
LABELS="flye,hifiasm,lja"
 
for A in "${ASSEMBLIES[@]}"; do
    if [[ ! -s "$A" ]]; then
        echo "ERROR: assembly not found or empty: $A" >&2
        exit 1
    fi
done
 
mkdir -p "$OUTDIR"
 
echo "Start: $(date)"
 
apptainer exec --bind /data "$CONTAINER" quast.py \
    "${ASSEMBLIES[@]}" \
    --labels "$LABELS" \
    --eukaryote \
    --est-ref-size "$EST_SIZE" \
    --threads "$THREADS" \
    -o "$OUTDIR"
 
echo "Finished: $(date)"
cat "$OUTDIR/report.txt"
 