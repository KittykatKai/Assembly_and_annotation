#!/bin/bash
#SBATCH --job-name=nucmer
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/nucmer_%j.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/nucmer_%j.err
#SBATCH --partition=pshort_el8
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch

set -euo pipefail
 
CONTAINER=/containers/apptainer/mummer4_gnuplot.sif
WORKDIR=/data/users/ksales/assembly_annotation_course
REF=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
OUTDIR=$WORKDIR/output_dir/nucmer
THREADS=${SLURM_CPUS_PER_TASK:-16}
 
FLYE=$WORKDIR/output_dir/flye/assembly.fasta
HIFIASM=$WORKDIR/output_dir/hifiasm/Pyl-1.bp.p_ctg.fa
LJA=$WORKDIR/output_dir/lja/assembly.fasta
 
for F in "$REF" "$FLYE" "$HIFIASM" "$LJA"; do
    if [[ ! -s "$F" ]]; then
        echo "ERROR: file not found or empty: $F" >&2
        exit 1
    fi
done
 
mkdir -p "$OUTDIR"
cd "$OUTDIR"
 
run_comparison () {
    local PREFIX=$1
    local R=$2
    local Q=$3
 
    echo "==== $PREFIX: $(date) ===="
 
    apptainer exec --bind /data "$CONTAINER" nucmer \
        --prefix "$PREFIX" \
        --breaklen 1000 \
        --mincluster 1000 \
        --threads "$THREADS" \
        "$R" "$Q"
 
    apptainer exec --bind /data "$CONTAINER" mummerplot \
        -R "$R" \
        -Q "$Q" \
        --filter \
        -t png \
        --large \
        --layout \
        --fat \
        -p "$PREFIX" \
        "$PREFIX.delta"
}
 
run_comparison ref_vs_flye       "$REF"     "$FLYE"
run_comparison ref_vs_hifiasm    "$REF"     "$HIFIASM"
run_comparison ref_vs_lja        "$REF"     "$LJA"
run_comparison flye_vs_hifiasm   "$FLYE"    "$HIFIASM"
run_comparison flye_vs_lja       "$FLYE"    "$LJA"
run_comparison hifiasm_vs_lja    "$HIFIASM" "$LJA"
 
echo "Finished: $(date)"
ls -lh "$OUTDIR"/*.png