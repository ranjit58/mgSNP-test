#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=process_ref
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --share
#SBATCH --mem=100000
#SBATCH --time=150:00:00
#SBATCH --output=process_ref.%j.out
#SBATCH --error=process_ref.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rkumar@uab.edu

### Import global variables ###
source ../mgSNP.config.txt
###

# create BWA index
bwa index genomes_ref.fa
 
# create samtools faidx index
samtools faidx genomes_ref.fa

# create picard dictionary
#java -jar ${PICARD}/picard.jar CreateSequenceDictionary R=genomes_ref.fa O=genomes_ref.fa.dict
java -jar ${PICARD}/picard.jar CreateSequenceDictionary R=genomes_ref.fa O=genomes_ref.dict
