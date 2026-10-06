#!/bin/bash
# Submits the whole analysis to SLURM in the correct order.
# Each job starts only once the jobs it depends on have finished successfully.
# Usage (from repo root): bash run_pipeline.sh
# Optional e-mail notifications: MAIL_USER=you@example.com bash run_pipeline.sh

set -euo pipefail
cd "$(dirname "$0")"
source config.sh
mkdir -p logs

MAIL_OPTS=()
[[ -n "${MAIL_USER:-}" ]] && MAIL_OPTS=("--mail-type=END,FAIL" "--mail-user=$MAIL_USER")

submit () {
    sbatch --parsable ${MAIL_OPTS[@]+"${MAIL_OPTS[@]}"} "$@" | cut -d';' -f1
}

after () {
    local IFS=:
    echo "--dependency=afterok:$*"
}

# Download the BUSCO lineage once, so parallel BUSCO jobs do not race to fetch it
if [[ ! -d "$OUT_DIR/busco/busco_downloads/lineages/$BUSCO_LINEAGE" ]]; then
    mkdir -p "$OUT_DIR/busco"
    apptainer exec --bind "$BIND" "$BUSCO_SIF" busco \
        --download "$BUSCO_LINEAGE" --download_path "$OUT_DIR/busco/busco_downloads"
fi

# 1. Quality control
submit scripts/01_qc/fastqc.sh > /dev/null
submit scripts/01_qc/fastp_hifi.sh > /dev/null
submit scripts/01_qc/fastp_rnaseq.sh > /dev/null

# 2. Assembly
declare -A JOB
JOB[flye]=$(submit scripts/02_assembly/flye.sh)
JOB[hifiasm]=$(submit scripts/02_assembly/hifiasm.sh)
JOB[lja]=$(submit scripts/02_assembly/lja.sh)
JOB[trinity]=$(submit scripts/02_assembly/trinity.sh)
MERYL=$(submit scripts/03_evaluation/meryl_db.sh)
GENOMES=("${JOB[flye]}" "${JOB[hifiasm]}" "${JOB[lja]}")

# 3. Evaluation
for A in flye hifiasm lja trinity; do
    submit "$(after "${JOB[$A]}")" --job-name="busco_$A" scripts/03_evaluation/busco.sh "$A" > /dev/null
done
for A in "${GENOME_ASSEMBLERS[@]}"; do
    submit "$(after "${JOB[$A]}" "$MERYL")" --job-name="merqury_$A" scripts/03_evaluation/merqury.sh "$A" > /dev/null
done
submit "$(after "${GENOMES[@]}")" scripts/03_evaluation/quast_no_ref.sh > /dev/null
submit "$(after "${GENOMES[@]}")" scripts/03_evaluation/quast_ref.sh > /dev/null

# 4. Comparison
submit "$(after "${GENOMES[@]}")" scripts/04_comparison/nucmer_mummerplot.sh > /dev/null

echo "All jobs submitted. Check progress with: squeue -u ${USER:-$(whoami)}"
echo "When everything has finished, run: bash collect_results.sh"
