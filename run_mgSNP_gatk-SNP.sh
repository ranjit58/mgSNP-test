#!/bin/bash
### Import global variables ###
source mgSNP.config.txt
###
cat ${GATK_SNP}/*/*_cmd.sh |shuf > temp_gatk-SNP.command
parallel -j $THREAD --joblog ${GATK_SNP}/parallel_log < temp_gatk-SNP.command
#rm temp_gatk-SNP.command

# To submit jobs on slurm cluster do
# sbatch GATK_SNP/*/*.job
