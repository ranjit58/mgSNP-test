#!/bin/bash
#SBATCH --partition=long
#SBATCH --job-name=bwa
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --share
#SBATCH --mem=100000
#SBATCH --time=150:00:00
#SBATCH --output=bwa.%j.out
#SBATCH --error=bwa.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rkumar@uab.edu

### Import global variables ###
source mgSNP.config.txt
###

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`
gunzip "${REF}.gz"
bwa index $REF
# create fasta index
samtools faidx $REF

# create sequence dictionary
java \
-Xmx8g \
-Djava.io.tmpdir=$TEMP \
-jar ${PICARD}/picard.jar CreateSequenceDictionary \
REFERENCE=$REF \
OUTPUT=$DICT

#parallel -j $INTHREAD mgSNP_bwa.sh ::: $SAMPLES_LIST
