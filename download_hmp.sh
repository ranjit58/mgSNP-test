#! /bin/bash

# INFO: Read a pairwise file samples.list (the first column in samples list) and download the files from amazon, uncompress them, rename them.
# Specify threads

### Import global variables ###
source mgSNP.config.txt
###


# Read pairwise list of samples in format " old_name	new_name"
declare -A samples
while read -r a b
do
        samples[$a]=$b

done < $SAMPLES_PAIR

# Place to store raw data
RAWDATA="RAWDATA_HMP"
mkdir $RAWDATA

function download(){
	# Using parallel to download raw data
	parallel -j $THREAD "aws s3 cp s3://human-microbiome-project/HHS/HMASM/WGS/stool/{}.tar.bz2 $RAWDATA/" ::: "${!samples[@]}"
}

function extract(){
	# Using parallel to extract files to same location
	parallel -j $THREAD "tar xjf {} -C $RAWDATA" ::: $RAWDATA/*.tar.bz2
}

function move(){

	# move files
    	mkdir $RAWDATA/temp
    	mv $RAWDATA/SRS* $RAWDATA/temp/
    	mv $RAWDATA/*/*1.fastq $RAWDATA
    	mv $RAWDATA/*/*2.fastq $RAWDATA
    	mv $RAWDATA/*/*/*1.fastq $RAWDATA
    	mv $RAWDATA/*/*/*2.fastq $RAWDATA
    	# deleting unnecessary files
    	rm -r $RAWDATA/temp
}

function change_name(){
	# rename files and move folders
	rename 's/.denovo_duplicates_marked.trimmed.1/_F/' $RAWDATA/*.fastq
	rename 's/.denovo_duplicates_marked.trimmed.2/_R/' $RAWDATA/*.fastq
}

# Call function in serial order
download
extract
move
change_name
