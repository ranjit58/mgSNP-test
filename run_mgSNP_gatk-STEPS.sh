#!/bin/bash
#SBATCH --partition=long
#SBATCH --job-name=gatk1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --share
#SBATCH --mem=200000
#SBATCH --time=150:00:00
#SBATCH --output=gatk1.%j.out
#SBATCH --error=gatk1.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rkumar@uab.edu

### Import global variables ###
source mgSNP.config.txt
###

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

mkdir $GATK_STEPS
parallel -j $THREAD x.sh  ::: $SAMPLES_LIST
#parallel -j $THREAD mgSNP_gatk.sh  ::: $SAMPLES_LIST
