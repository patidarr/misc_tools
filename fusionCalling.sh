
module load STAR/2.6.1c
STAR   	--runThreadN 8\
	--genomeDir /data/MoCha/patidarr/ref/Index/STAR_hg19_index\
	--readFilesIn $R1 $R2 \
	--readFilesCommand zcat\
	--limitBAMsortRAM 12000000000\
	--outFileNamePrefix $dir\
	--outSAMtype BAM   SortedByCoordinate\
	--outSAMattributes NH   NM   MD\
	--outSAMmapqUnique 50\
	--outSAMattrRGline ID:1   SM:UHR\
	--outSJfilterCountUniqueMin -1   2   2   2\
	--outSJfilterCountTotalMin -1   2   2   2\
	--outFilterType BySJout\
	--outFilterIntronMotifs RemoveNoncanonical\
	--chimSegmentMin 12\
	--chimScoreDropMax 30\
	--chimScoreSeparation 5\
	--chimJunctionOverhangMin 12\
	--chimOutType WithinBAM\
	--chimSegmentReadGapMax 5\
	--sjdbGTFfile $GTF\
	--twopassMode Basic

module load  picard
java -jar /usr/local/apps/picard/2.18.27/picard.jar MarkDuplicates\
	INPUT=$dir/Aligned.sortedByCoord.out.bam\
	OUTPUT=$dir/${sample}.bam\
	METRICS_FILE=$dir/${sample}.dd.mat\
	CREATE_INDEX=true\
	MAX_SEQUENCES_FOR_DISK_READ_ENDS_MAP=50000\
	MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=8000\
	SORTING_COLLECTION_SIZE_RATIO=0.25\
	PROGRAM_RECORD_ID=MarkDuplicates\
	PROGRAM_GROUP_NAME=MarkDuplicates\
	REMOVE_DUPLICATES=false\
	ASSUME_SORTED=false\
	DUPLICATE_SCORING_STRATEGY=SUM_OF_BASE_QUALITIES\
	OPTICAL_DUPLICATE_PIXEL_DISTANCE=100\
	VERBOSITY=INFO\
	QUIET=false\
	VALIDATION_STRINGENCY=STRICT\
	COMPRESSION_LEVEL=5\
	MAX_RECORDS_IN_RAM=500000\
	CREATE_MD5_FILE=false


module load manta
configManta.py --bam $dir/${sample}.bam\
	--referenceFasta /data/MoCha/patidarr/ref/ucsc.hg19.fasta\
	--runDir $dir/manta\
	--generateEvidenceBam \
	--rna \
	--unstranded \
	--generateEvidence \
	--outputContig \
	--exome \
	--callRegions $region\
	--config $config

$dir/manta/runWorkflow.py -m local -j ${SLURM_CPUS_ON_NODE}
