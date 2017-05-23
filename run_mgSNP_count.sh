#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=get_count
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --share
#SBATCH --mem=10000
#SBATCH --time=48:00:00
#SBATCH --output=get_count.%j.out
#SBATCH --error=get_count.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rkumar@uab.edu


### Import global variables ###
source mgSNP.config.txt
###

mkdir READ-COUNT

mkdir READ-COUNT/RAW-COUNT
parallel -j $THREAD5 "zcat {} | wc -l> READ-COUNT/RAW-COUNT/{/.}_rawcount.txt" ::: ${RAWDATA}/*.gz
parallel -j $THREAD5 "wc -l {} > READ-COUNT/RAW-COUNT/{/.}_rawcount.txt" ::: ${RAWDATA}/*.fastq

mkdir READ-COUNT/BAM-COUNT
parallel -j $THREAD5 "samtools flagstat {} > READ-COUNT/BAM-COUNT/{/.}.flagstat" ::: ${BWA_FILES}/*.sam

mkdir READ-COUNT/BAM-FIL-COUNT
parallel -j $THREAD5 "samtools flagstat {} > READ-COUNT/BAM-FIL-COUNT/{/.}.flagstat" ::: ${BWA_FILTERED}/*.sam

mkdir READ-COUNT/GATK-COUNT
parallel -j $THREAD5 "samtools flagstat {} > READ-COUNT/GATK-COUNT/{/.}.flagstat" ::: ${GATK_STEPS}/*.bam
