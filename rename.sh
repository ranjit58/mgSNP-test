# To rename files in a diretory

old='denovo_duplicates_marked.trimmed.1'
new='_F'
for sample in `ls test`
do
	echo $sample 
	x=${sample/den/xxx}
	echo $x
done
