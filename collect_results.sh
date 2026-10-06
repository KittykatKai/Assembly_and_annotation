#!/bin/bash
# Copies the small summary files from output_dir/ into results/ for version control.
# Usage (from repo root, after the pipeline has finished): bash collect_results.sh

set -uo pipefail
cd "$(dirname "$0")" || exit 1
source config.sh

copy () {
    local DEST=$1; shift
    mkdir -p "$DEST"
    for F in "$@"; do
        if [[ -f "$F" ]]; then cp "$F" "$DEST/"; else echo "Not found (step not finished?): $F"; fi
    done
}

copy results/01_qc "$OUT_DIR"/fastqc/*_fastqc.html "$OUT_DIR"/fastp/*_fastp.html

copy results/03_evaluation/busco "$OUT_DIR"/busco/*/short_summary*.txt

for TYPE in no_reference with_reference; do
    mkdir -p results/03_evaluation/quast
    for EXT in txt tsv pdf; do
        F="$OUT_DIR/quast/$TYPE/report.$EXT"
        [[ -f "$F" ]] && cp "$F" "results/03_evaluation/quast/${TYPE}_report.$EXT"
    done
done

for A in "${GENOME_ASSEMBLERS[@]}"; do
    copy results/03_evaluation/merqury \
        "$OUT_DIR/merqury/$A/$A.qv" \
        "$OUT_DIR/merqury/$A/$A.completeness.stats" \
        "$OUT_DIR"/merqury/"$A"/*.spectra-cn.fl.png
done

copy results/04_comparison/nucmer "$OUT_DIR"/nucmer/*.png

echo "Done. Total size of results/: $(du -sh results | cut -f1)"
