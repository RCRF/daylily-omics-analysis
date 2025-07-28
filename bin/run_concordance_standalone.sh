#!/usr/bin/env bash

# Usage: ./run_concordance.sh <path_to_calls_vcf.gz> <path_to_truth_dir>
# Required env vars:
#   ALIGNER, SNV_CALLER, ALT_NAME, SDF_PATH, OUT_DIR, CLUSTER_SAMPLE
# Optional env vars:
#   SUB_THREADS (default: 7)

export ALIGNER="ultimaB"
export SNV_CALLER="ultimaD"
export ALT_NAME="HG001"
export SDF_PATH="/fsx/data/genomic_data/organism_references/H_sapiens/hg38/fasta_fai_minalt/GRCh38_no_alt_analysis_set.fasta.sdf/"
export OUT_DIR=$PWD/manual_results/concordance/
mkdir -p "$OUT_DIR"
export CLUSTER_SAMPLE="HG001"
export SUB_THREADS=7

set -euo pipefail

# --- Inputs ---
CVCF="$1"
TRUTH_DIR="$2"
TBI="${CVCF}.tbi"

# --- Required env vars ---
: "${ALIGNER:?Need ALIGNER set}"
: "${SNV_CALLER:?Need SNV_CALLER set}"
: "${ALT_NAME:?Need ALT_NAME set}"
: "${SDF_PATH:?Need SDF_PATH set}"
: "${OUT_DIR:?Need OUT_DIR set}"
: "${CLUSTER_SAMPLE:?Need CLUSTER_SAMPLE set}"
: "${SUB_THREADS:=7}"

# --- Output paths ---
CONC_DIR="${OUT_DIR}/concordance"
LOG="${CONC_DIR}/logs/${CLUSTER_SAMPLE}.${ALIGNER}.${SNV_CALLER}.concordance.log"
FOFN="${CONC_DIR}/concordance.fofn"
FIN_CMDS="${CONC_DIR}/concordance.fin.cmds"
DONE_SENTINEL="${CONC_DIR}/concordance.done"

mkdir -p "$(dirname "$FOFN")" "$CONC_DIR/logs"
echo "" > "$FOFN"
echo "" > "$FIN_CMDS"

# --- Use only the base truth dir ---
BED="${TRUTH_DIR}/${ALT_NAME}.bed"
VCF="${TRUTH_DIR}/${ALT_NAME}.vcf.gz"

if [[ ! -f "$BED" || ! -f "$VCF" ]]; then
    echo "Missing truth files: $BED or $VCF" >> "$LOG"
    echo "Skipping due to missing truth files"
    touch "$DONE_SENTINEL" "${DONE_SENTINEL}.SKIPPED"
    exit 0
fi

# --- Create RTG vcfeval + parsing commands ---
OUT_SUBD="${CONC_DIR}/_${ALT_NAME}"
rm -rf "$OUT_SUBD" || true

CMD="rtg vcfeval --decompose --squash-ploidy --ref-overlap -e $BED -b $VCF -c $CVCF -o $OUT_SUBD -t $SDF_PATH --threads $SUB_THREADS"
FIN="python workflow/scripts/parse-vcfeval-summary.py $OUT_SUBD/summary.txt $CLUSTER_SAMPLE $BED $ALT_NAME $CONC_DIR_${ALT_NAME}/${CLUSTER_SAMPLE}_${ALT_NAME}_summary.txt na $ALIGNER $SNV_CALLER"

echo "$CMD >> ${CONC_DIR}_a.err 2>&1; $FIN >> ${CONC_DIR}_b.err 2>&1;" >> "$FOFN"

# --- Execute commands ---
bash "$FOFN" >> "$LOG" 2>&1

# --- Finalization ---
touch "$DONE_SENTINEL"
echo "Concordance done for $CLUSTER_SAMPLE" >> "$LOG"
