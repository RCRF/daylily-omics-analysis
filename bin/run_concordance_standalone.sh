#!/usr/bin/env bash

# Usage: ./run_concordance.sh <path_to_calls_vcf.gz> <path_to_truth_dir>
# Required env vars:
#   ALIGNER, SNV_CALLER, ALT_NAME, SDF_PATH, OUT_DIR, CLUSTER_SAMPLE, SUB_THREADS

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

# --- Required params from environment ---
: "${ALIGNER:?Need ALIGNER set}"
: "${SNV_CALLER:?Need SNV_CALLER set}"
: "${ALT_NAME:?Need ALT_NAME set}"
: "${SDF_PATH:?Need SDF_PATH set}"
: "${OUT_DIR:?Need OUT_DIR set}"
: "${CLUSTER_SAMPLE:?Need CLUSTER_SAMPLE set}"
: "${SUB_THREADS:=7}"

# --- Derived paths ---
CONC_DIR="${OUT_DIR}/concordance"
LOG="${CONC_DIR}/logs/${CLUSTER_SAMPLE}.${ALIGNER}.${SNV_CALLER}.concordance.log"
FOFN="${CONC_DIR}/concordance.fofn"
FIN_CMDS="${CONC_DIR}/concordance.fin.cmds"
DONE_SENTINEL="${CONC_DIR}/concordance.done"

mkdir -p "$(dirname "$FOFN")" "$CONC_DIR/logs"

# --- Initialize files ---
echo "" > "$FOFN"
echo "" > "$FIN_CMDS"

export allvar_mean_dp="na"

# Safety fallback
if [[ -z "$ALIGNER" ]]; then ALIGNER="na"; fi
if [[ -z "$SNV_CALLER" ]]; then SNV_CALLER="na"; fi

# If no valid concordance directory string is set, skip
if [[ ${#CONC_DIR} -le 6 ]]; then
    echo "WARNING: concordance not configured, skipping." >&2
    touch "$DONE_SENTINEL" "${DONE_SENTINEL}.SKIPPED"
    exit 0
fi

# --- Main processing loop ---
for BED in "$TRUTH_DIR"/*/"$ALT_NAME.bed"; do
    SUBD=$(basename "$(dirname "$BED")")
    VCF="${TRUTH_DIR}/${SUBD}/${ALT_NAME}.vcf.gz"

    if [[ ! -f "$VCF" || ! -f "$BED" ]]; then
        echo "Missing truth files for $SUBD, skipping" >> "$LOG"
        continue
    fi

    OUT_SUBD="${CONC_DIR}/_${SUBD}"
    rm -rf "$OUT_SUBD" || true

    CMD="rtg vcfeval --decompose --squash-ploidy --ref-overlap -e $BED -b $VCF -c $CVCF -o $OUT_SUBD -t $SDF_PATH --threads $SUB_THREADS"
    FIN="python workflow/scripts/parse-vcfeval-summary.py $OUT_SUBD/summary.txt $CLUSTER_SAMPLE $BED $SUBD $ALT_NAME ${CONC_DIR}_${SUBD}/${CLUSTER_SAMPLE}_${SUBD}_summary.txt $allvar_mean_dp $ALIGNER $SNV_CALLER"

    echo "$CMD >> ${CONC_DIR}_a.err 2>&1; $FIN >> ${CONC_DIR}_b.err 2>&1;" >> "$FOFN"
done

# --- Execute commands ---
cat "$FOFN" | bash >> "$LOG" 2>&1

# --- Finalization ---
touch "$DONE_SENTINEL"
echo "Concordance done for $CLUSTER_SAMPLE" >> "$LOG"
