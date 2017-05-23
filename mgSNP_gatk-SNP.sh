
### Import global variables ###
source mgSNP.config.txt
###

#SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

mkdir ${GATK_SNP}

while read line
do
        GENOME_NAME=` echo "$line" | cut -d ':' -f 1`
        mkdir ${GATK_SNP}/$GENOME_NAME

        while read sample
        do
                SAMPLE_NAME=`echo "$sample" | cut -d '/' -f 2 | cut -d '_' -f 1`
                echo -e "java -Xmx10g -jar $GATK/GenomeAnalysisTK.jar -T HaplotypeCaller -R $REF -L $line --sample_ploidy 1 -I $sample --emitRefConfidence BP_RESOLUTION -o ${GATK_SNP}/$GENOME_NAME/${SAMPLE_NAME}.g.vcf"  >> ${GATK_SNP}/$GENOME_NAME/${GENOME_NAME}_cmd.sh
        done < $BAM_LIST

# create a job file for sbatch submission
cat <<EOF > ${GATK_SNP}/$GENOME_NAME/${GENOME_NAME}.job
#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=${GENOME_NAME}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --mem=250000
#SBATCH --time=48:00:00
#SBATCH --output=${GENOME_NAME}.%N.%j.out
#SBATCH --error=${GENOME_NAME}.%N.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rkumar@uab.edu

cat ${GENOME_NAME}_cmd.sh | parallel -j $THREAD --joblog log
#gzip *.vcf

EOF

# Turn on to automatically submit jobs or later do sbatch GATK_SNP/*/*.job
#sbatch ${GENOME_NAME}.job

done < $GENOME_LIST
