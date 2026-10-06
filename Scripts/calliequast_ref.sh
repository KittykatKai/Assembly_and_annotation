#!/bin/bash
#SBATCH --job-name=Quast_ref
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/quast_ef_%j.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/quast_ref_%j.err
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pshort_el8
#SBATCH --array=0-0
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch

set -euo pipefail
 
CONTAINER=/containers/apptainer/quast_5.2.0.sif
WORKDIR=/data/users/ksales/assembly_annotation_course
REF_DIR=/data/courses/assembly-annotation-course/references
OUTDIR=$WORKDIR/output_dir/quast/with_reference
THREADS=${SLURM_CPUS_PER_TASK:-16}
 
ASSEMBLIES=(
    "$WORKDIR/output_dir/flye/assembly.fasta"
    "$WORKDIR/output_dir/hifiasm/Pyl-1.bp.p_ctg.fa"
    "$WORKDIR/output_dir/lja/assembly.fasta"
)
LABELS="flye,hifiasm,lja"
 
REF=$REF_DIR/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
GFF=$REF_DIR/Arabidopsis_thaliana.TAIR10.57.gff3
 
for A in "${ASSEMBLIES[@]}"; do
    if [[ ! -s "$A" ]]; then
        echo "ERROR: assembly not found or empty: $A" >&2
        exit 1
    fi
done
 
mkdir -p "$OUTDIR"
 
echo "Start: $(date)"
echo "Reference:  $REF"
echo "Annotation: $GFF"
 
apptainer exec --bind /data "$CONTAINER" quast.py \
    "${ASSEMBLIES[@]}" \
    --labels "$LABELS" \
    -r "$REF" \
    --features "$GFF" \
    --eukaryote \
    --threads "$THREADS" \
    -o "$OUTDIR"
 
echo "Finished: $(date)"
cat "$OUTDIR/report.txt"