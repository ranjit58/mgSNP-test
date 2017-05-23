#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=sam-filter
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --share
#SBATCH --mem=200000
#SBATCH --time=48:00:00
#SBATCH --output=sam-filter.%j.out
#SBATCH --error=sam-filter.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rkumar@uab.edu

### Import global variables ###
source mgSNP.config.txt
###

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

mkdir $BWA_FILTERED

parallel -j $THREAD "mgSNP_sam-filter.py -i ${BWA_FILES}/{}.sam -o ${BWA_FILTERED}/{}.filtered.sam" ::: $SAMPLES_LIST
parallel -j $THREAD "grep -v "XA:" ${BWA_FILTERED}/{}.filtered.sam > ${BWA_FILTERED}/{}.filtered2.sam" ::: $SAMPLES_LIST
#parallel -j $THREAD "rm {}.filtered.sam" ::: $SAMPLES_LIST
#parallel -j $THREAD "mv {}.filtered2.sam {}.filtered.sam" ::: $SAMPLES_LIST
