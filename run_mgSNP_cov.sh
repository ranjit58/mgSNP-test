#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=get_cov
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --share
#SBATCH --mem=10000
#SBATCH --time=48:00:00
#SBATCH --output=get_cov.%N.%j.out
#SBATCH --error=get_cov.%N.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rkumar@uab.edu


### Import global variables ###
source mgSNP.config.txt
###

mkdir $COV_STATS

while read line
do
        GENOME_NAME=` echo "$line" | cut -d ':' -f 1`
        mkdir $COV_STATS/$GENOME_NAME

        #parallel -j $THREAD5 "vcftools --vcf {} --depth --out $COV_STATS/$GENOME_NAME/d1_{/.} --minDP 1" ::: ${GATK_SNP}/${GENOME_NAME}/*.vcf

        rm $COV_STATS/$GENOME_NAME/${GENOME_NAME}_d1.stats
        echo -ne "$GENOME_NAME\t" > $COV_STATS/$GENOME_NAME/${GENOME_NAME}_d1.stats && cat $COV_STATS/$GENOME_NAME/d1_*.idepth | grep -v "MEAN_DEPTH" | tr "\n" "\t" >> $COV_STATS/$GENOME_NAME/${GENOME_NAME}_d1.stats

done < $GENOME_LIST
