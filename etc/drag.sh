dragen \
    --fastq-list=./dragen_ss.csv \
    --fastq-list-sample-id=HG001 \
    -r  /fsx/scratch/dragen_ref/hg38_dragen/ \
    --output-directory $PWD/results/ \
    --output-file-prefix hg001 \
    --validate-pangenome-reference=false \
    --events-log-file=$PWD/results/dragen_events.csv \
    --enable-metrics-json=true \
    --enable-variant-caller=true \
    --vc-enable-bqd=true \
    --vc-enable-vcf-output=true \
    --vc-emit-ref-confidence=GVCF \
    --vc-enable-mapq-zero-regions=true \
    --vc-ml-enable-recalibration=true \
    --enable-vcf-compression=true \
    --enable-ploidy-estimator=true \
    --sample-sex=auto \
    --enable-map-align=true \
    --enable-map-align-output=true \
    --output-format=CRAM \
    --enable-bam-indexing=true \
    --enable-duplicate-marking=true \
    --lic-credentials $CREDFILE

dragen \
    --fastq-list=./dragen_ss.csv \
    -r  /fsx/scratch/dragen_ref/hg38_dragen/ \
    --output-directory $PWD/results_all/ \
    --validate-pangenome-reference=false \
    --events-log-file=$PWD/results_all/dragen_events.csv \
    --enable-metrics-json=true \
    --enable-variant-caller=true \
    --vc-enable-bqd=true \
    --vc-enable-vcf-output=true \
    --vc-emit-ref-confidence=GVCF \
    --vc-enable-mapq-zero-regions=true \
    --vc-ml-enable-recalibration=true \
    --enable-vcf-compression=true \
    --enable-ploidy-estimator=true \
    --sample-sex=auto \
    --enable-map-align=true \
    --enable-map-align-output=true \
    --output-format=CRAM \
    --enable-bam-indexing=true \
    --enable-duplicate-marking=true \
    --lic-credentials $CREDFILE --fastq-list-all-samples

ssh -i ~/.ssh/lsmc-omics-us-west-2.pem ec2-user@ec2-54-149-228-174.us-west-2.compute.amazonaws.com


for SAMPLE in HG001 HG002 HG003 HG004 HG005 HG006 HG007; do
    mkdir -p "$PWD/results_all/${SAMPLE}"
    dragen \
    --fastq-list=./dragen_ss.csv \
    --fastq-list-sample-id="$SAMPLE" \
    -r /fsx/scratch/dragen_ref/hg38_dragen/ \
    --output-directory="$PWD/results_all/${SAMPLE}" \
    --output-file-prefix="${SAMPLE}" \
    --validate-pangenome-reference=false \
    --events-log-file="$PWD/results_all/${SAMPLE}/dragen_events.csv" \
    --enable-metrics-json=true \
    --enable-variant-caller=true \
    --vc-enable-bqd=true \
    --vc-enable-vcf-output=true \
    --vc-emit-ref-confidence=GVCF \
    --vc-enable-mapq-zero-regions=true \
    --vc-ml-enable-recalibration=true \
    --enable-vcf-compression=true \
    --enable-ploidy-estimator=true \
    --sample-sex=auto \
    --enable-map-align=true \
    --enable-map-align-output=true \
    --output-format=CRAM \
    --enable-bam-indexing=true \
    --enable-duplicate-marking=true \
    --lic-credentials  ./dragen.cfg 
done




dragen.lisc file in format
```
credentials-1=YOURSTRING
credentials-2=YOURSTRING
```

# NEW COMMAND
SAMPLE="HG002"
mkdir -p $PWD/results_all/${SAMPLE}/
mkdir -p $PWD/results_all/${SAMPLE}/tmp/

dragen \
--ref-dir=/fsx/scratch/dragen_ref/hg38_pangenome/ \
--fastq-list=./dragen_ss.csv \
--fastq-list-sample-id="$SAMPLE" \
--validate-pangenome-reference=true \
--intermediate-results-dir=$PWD/results_all/${SAMPLE}/tmp/ \
--output-directory="$PWD/results_all/${SAMPLE}" \
--output-file-prefix="${SAMPLE}" \
--enable-map-align=true \
--enable-map-align-output=true \
--enable-sort=true \
--enable-duplicate-marking=true \
--enable-variant-caller=true \
--enable-variant-annotation=false \
--enable-sv=true \
--enable-cnv=true \
--cnv-enable-self-normalization=true \
--enable-hla=false \
--enable-targeted=true \
--enable-star-allele=false \
--enable-pgx=false \
--repeat-genotype-enable=true \
--enable-mrjd=true \
--mrjd-enable-high-sensitivity-mode=true \
--enable-personalization=true 

