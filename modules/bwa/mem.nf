
RG="@RG\tID:$FLOWCELL.$LANE\tSM:$STUDY.$SAMPLE\tPL:illumina\tLB:lib$LIBRARY\tPU:$FLOWCELL.$LANE.$INDEX"

$BWA mem -M -t $BWA_THREADS -R $RG $REFERENCE $SEQ_R1 $SEQ_R2 | $SAMTOOLS sort -@ $SAMTOOLS_THREADS -O BAM -o $OUT_DIR/mapped_singles/$UNIQUE_ID.sorted_reads.bam -
