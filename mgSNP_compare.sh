#!/bin/bash
### Import global variables ###
source mgSNP.config.txt
###

mkdir $COMPARE

while read line
do

			genome=` echo "$line" | cut -d ' ' -f 1`
			mkdir  $COMPARE/$genome

	count=1
        #while read sample
        #do
        #        array[$count]=$sample
	#	count=$[$count +1]
        #done < samples.list
	#echo $count
	#genome="Prevotella_copri_DSM_18205"
	array=(`echo "$line" | cut -d ' ' -f 2-`)
	count=${#array[@]}
	#echo $count
	for (( i=0; i<$((count - 1 )); i++ ))
	do
	#	echo ${array[@]:$i}
	#done

  cat <<EOF > $COMPARE/$genome/z${genome}_${i}.job
#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=z${genome}_${i}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --share
#SBATCH --mem=10000
#SBATCH --time=24:00:00
#SBATCH --output=z${genome}_${i}.%N.%j.out
#SBATCH --error=z${genome}_${i}.%N.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rkumar@uab.edu

	LIST_SAMPLES="`echo ${array[@]:$i}`"

	OUT=`echo "$COMPARE/$genome/z${genome}_${i}.out"`
	echo -en "" >\$OUT

	#echo -e "Working on genome $genome"
	set -- \$LIST_SAMPLES
	for a; do
    		shift
    		for b; do
			shift
			echo -en "${genome}:\${a}:\${b}=" >> \$OUT
			echo -e "\$a\n\$b" > $COMPARE/$genome/ids${i}
			vcftools --vcf ${GATK_MULTISNP}/${genome}/${genome}.vcf --keep $COMPARE/$genome/ids${i} --remove-indels --recode -c > $COMPARE/$genome/temp${i}.vcf
			mgSNP_annotator.py -i $COMPARE/$genome/temp${i}.vcf -o $COMPARE/$genome/temp${i}.ann
                        GETNAME=\`echo ${genome},length=\`
                        GETSTR=\`grep "\$GETNAME" < ${GATK_MULTISNP}/${genome}/${genome}.vcf\`
                        GETLENGTH=\`echo \$GETSTR | cut -d '=' -f 4 | tr -d '>'\`
			XX=\`mgSNP_windowmaker.py -i $COMPARE/$genome/temp${i}.ann -o $COMPARE/$genome/temp${i}.win -w 1000 -g \$GETLENGTH\`
			echo -en "\${XX}\n" >> \$OUT

		done
	done

	rm $COMPARE/$genome/temp${i}.vcf
	rm $COMPARE/$genome/temp${i}.ann
	rm $COMPARE/$genome/temp${i}.win
	rm $COMPARE/$genome/ids${i}
EOF

#sbatch z${genome}_${i}.job

done

done < $LIST_FOR_COMPARE
