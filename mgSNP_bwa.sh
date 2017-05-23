#Run BWA
#Threads to run

### Import global variables ###
source mgSNP.config.txt
###

SAMPLE=$1
mkdir $BWA_FILES

# preparing readgroup info
READGROUP="@RG\tID:G${SAMPLE}\tSM:${SAMPLE}\tPL:Illumina\tLB:lib1\tPU:unit1"

# alignment using BWA MEM with -M and -R options
#bwa mem -M -t $THREAD -R $READGROUP $REF ../RAWDATA_QC/${SAMPLE}_F.fastq ../RAWDATA_QC/${SAMPLE}_R.fastq > ${SAMPLE}.sam

#use if trimmomatic is used
bwa mem -M -t $INTHREAD -R $READGROUP $REF ${RAWDATA}/${SAMPLE}_F_P.fastq ${RAWDATA}/${SAMPLE}_R_P.fastq > $BWA_FILES/${SAMPLE}.sam

#bwa mem -M -t $THREAD -R $READGROUP ${REF} ${RAWDATA}/${SAMPLE}_F.fastq ${RAWDATA}/${SAMPLE}_R.fastq > $BWA_FILES/${SAMPLE}.sam

echo -e "\nINFO: BWA alignment complete for sample ${SAMPLE}"
