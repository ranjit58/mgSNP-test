#!/bin/bash

### Import global variables ###
source mgSNP.config.txt
###

#SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

mkdir ${GATK_MULTISNP}

while read line
do

        GENOME_NAME=` echo "$line" | cut -d ':' -f 1`

	mkdir ${GATK_MULTISNP}/$GENOME_NAME


	cat <<EOF > ${GATK_MULTISNP}/$GENOME_NAME/${GENOME_NAME}.job
#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=${GENOME_NAME}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --share
#SBATCH --mem=50000
#SBATCH --time=48:00:00
#SBATCH --output=${GENOME_NAME}.%N.%j.out
#SBATCH --error=${GENOME_NAME}.%N.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rkumar@uab.edu

ls ${GATK_SNP}/$GENOME_NAME/*.g.vcf > ${GATK_MULTISNP}/$GENOME_NAME/allvcf.list
java -Xmx25g -jar $GATK/GenomeAnalysisTK.jar -T GenotypeGVCFs -R $REF --sample_ploidy 1 --variant ${GATK_MULTISNP}/$GENOME_NAME/allvcf.list --includeNonVariantSites -o ${GATK_MULTISNP}/$GENOME_NAME/${GENOME_NAME}.vcf

EOF

# Turn on to automatically submit jobs or later do sbatch GATK_MULTISNP/*/*.job
#sbatch ${GENOME_NAME}.job

done < $GENOME_LIST
