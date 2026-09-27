#!/bin/bash
#SBATCH --job-name=fastqcPyl
#SBATCH --output=/data/users/ksales/assembly_annotation_course/output_dir/fastqc_out/fastqc_%A_%a.out
#SBATCH --error=/data/users/ksales/assembly_annotation_course/output_dir/error_out/fastqc_%A_%a.err
#SBATCH --time=02:10:00
#SBATCH --mem=1G
#SBATCH --array=0-0
#SBATCH --cpus-per-task=1
#SBATCH --partition=pibu_el8
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kai.sales@students.unibe.ch

# Set paths
CONTAINER="/containers/apptainer/fastqc-0.12.1.sif"
INPUT_DIR="/data/users/ksales/assembly_annotation_course/Pyl-1"
OUTPUT_DIR="/data/users/ksales/assembly_annotation_course/output_dir/fastqc_out"

# Array of sample IDs (using array in this situation is more efficent)
samples=(
ERR11437347
)

#  sample for array
sample=${samples[$SLURM_ARRAY_TASK_ID]}

# Run FastQC using Apptainer container
apptainer exec --bind /data:/data "$CONTAINER" fastqc \
    "$INPUT_DIR"/${sample}.fastq.gz \
    -o "$OUTPUT_DIR" \
    -t $SLURM_CPUS_PER_TASK
    