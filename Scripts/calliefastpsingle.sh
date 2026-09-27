#!/bin/bash
#SBATCH --job-name=fastpPyl1
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/fastp_%A_%a.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/fastp_%A_%a.err
#SBATCH --time=02:10:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=4
#SBATCH --partition=pibu_el8
#SBATCH --array=0-0
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch

# Set Paths
CONTAINER="/containers/apptainer/fastp_0.24.1.sif"
INPUT_DIR="/data/users/ksales/assembly_annotation_course/Pyl-1"
OUTPUT_DIR="/data/users/ksales/assembly_annotation_course/output_dir"

# Array of sample IDs
samples=(
ERR11437347
)

# Get sample for array
sample=${samples[$SLURM_ARRAY_TASK_ID]}

apptainer exec --bind /data:/data "$CONTAINER" fastp \
    -i "$INPUT_DIR"/${sample}.fastq.gz \
    -o "$OUTPUT_DIR"/${sample}_trimmed.fastq.gz \
    -h "$OUTPUT_DIR"/${sample}_fastp.html \
    -j "$OUTPUT_DIR"/${sample}_fastp.json \
    --thread 4 \
    --detect_adapter_for_pe \
    --length_required 20 \
    --cut_front \
    --cut_tail \
    --cut_window_size 4 \
    --cut_mean_quality 20