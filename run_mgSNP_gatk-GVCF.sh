#!/bin/bash
### Import global variables ###
source mgSNP.config.txt
###

cat ${GATK_MULTISNP}/*/*.job |grep -v "SBATCH" | grep -v "bash" > temp_gatk-GCF.commandlist
parallel -j $THREAD1 --joblog ${GATK_SNP}/parallel_log < temp_gatk-GCF.commandlist
#rm temp_gatk-GCF.commandlist

# To submit jobs on slurm cluster do
# sbatch MULTISNP/*/*.job
