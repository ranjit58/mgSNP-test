#!/usr/bin/python

import os, sys, getopt

#Assumption - It reads ouput of multisample SNP calling from GATK. The output is parsed using VCFTools to include just two samples for comparision. The samples two lines of input looks like as giebn below
##CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  D1      RpT1m6
#Bacteroides_vulgatus_PC510      784     .       A       G       811.11  .       .       GT:AD:DP:GQ:PL  0:47,0:47:99:0,2004     0:79,0:79:99:0,3361

# read input file as command line option

infile=''
outfile=''
GENOME_SIZE = 0
WINDOW_SIZE = 0

# defines arguments and how to process them
myopts, args = getopt.getopt(sys.argv[1:],"i:o:g:w:")

for o, a in myopts:
    if o == '-i':
        infile=a
    elif o == '-o':
        outfile=a
    elif o == '-g':
        GENOME_SIZE = int(a)
    elif o == '-w':
        WINDOW_SIZE = int(a)
    else:
        print("Usage: %s -i input -o output -g genomesize -w windowsize" % sys.argv[0])
	sys.exit()

if GENOME_SIZE == 0 or WINDOW_SIZE == 0:
	print "\nERROR: Genome size or windowsize not provided"
	print("ERROR: Usage: %s -i input -o output -g genomesize -w windowsize" % sys.argv[0]) 
	print ("ERROR: The supplied parameters were, Input-%s , output-%s ,genome size-%s,  and windowsize-%s\n" % (infile,outfile,GENOME_SIZE,WINDOW_SIZE) )
	sys.exit()
#print ("TEST: The supplied parameters were, Input-%s , output-%s ,genome size-%s,  and windowsize-%s\n" % (infile,outfile,GENOME_SIZE,WINDOW_SIZE) )


#Open input file
INFILE = ''
OUTFILE = ''
if os.path.isfile(infile):
	try:
		INFILE  = open(infile, "r")
###       		print "\nINFO: Reading input file " + infile
	except IOError:
		print 'ERROR: Cannot open file ', + infile 
		sys.exit()
else:
	print "ERROR: Input file " + infile + " not found"
	sys.exit()

try:
	OUTFILE  = open(outfile, "w")
###	print "INFO: Opened  output file " + outfile + " for writing"
except IOError:
	print 'ERROR: Cannot open file ', + outfile
	sys.exit()

# Now implementing window based approach to count window where SNP pattern is same and where SNP pattern is different

pointer_line = 0
pointer_lastpos = 0

count_LOW_COVERAGE = 0
count_NO_SNP = 0
count_DIFFERENT = 0
count_SAME_SNP = 0
count_DIFFERENT_SNP_01 = 0
count_DIFFERENT_SNP_10 = 0
count_SAME = 0
count_NOIDEA = 0
COV_cutoff = 0.5 # 50% of the window should have high coverage (i.e not annotated as LOW_COV  to be considered

for window in range(1,GENOME_SIZE,WINDOW_SIZE): 
	START = window
	END = window + WINDOW_SIZE - 1
	OUTFILE.write(str(START) + "\t" + str(END) + "\t")
	
	num_SNPs = 0
	RESULT = ''
	count_LOW_COV = 0
	count_GOOD_COV = 0

	while pointer_line <= END:
		# set defualt result as NODATA

		line = INFILE.readline()
		if not line:
        		break
		if not line.startswith('#'):
			#print line
			line = line.rstrip('\r\n|\n')  # to remove endlines if any
			tabs = line.split()
			col1 = tabs[1]
			col11 = tabs[11]
			
			col11_1 = col11.split(':')[0]
			col11_2 = col11.split(':')[1]
			
			pointer_line = int(col1)
			if pointer_line <= END:
				#OUTFILE.write(line + "\n")

				# SNP comparision goes here
				if col11_1 == 'LOW_COV':
					count_LOW_COV += 1
                                elif col11_1 == 'SKIP_NO_SNP' or col11_1 == 'SKIP_HighAlleleFreq' or col11_1 == 'SKIP_MULTIALLELE':
                                        count_GOOD_COV += 1
				elif col11_1 == 'SKIP_SAME_SNP':
					num_SNPs += 1
					count_SAME_SNP += 1
					count_GOOD_COV += 1
				elif col11_1 == 'DIFFERENT_SNP_10':
					num_SNPs += 1
					count_DIFFERENT_SNP_10 += 1
					count_GOOD_COV += 1
					RESULT = 'DIFFERENT'
                                elif col11_1 == 'DIFFERENT_SNP_01':
                                        num_SNPs += 1
					count_DIFFERENT_SNP_01 += 1
					count_GOOD_COV += 1
                                        RESULT = 'DIFFERENT'
			
				pointer_lastpos = INFILE.tell()
			else:
				INFILE.seek(pointer_lastpos)
	
        try:
        	percent_LOW_COV = float(count_LOW_COV) / float(count_LOW_COV + count_GOOD_COV)        
	except ZeroDivisionError:
                        percent_LOW_COV = 0


        try:
       		percent_GOOD_COV = float(count_GOOD_COV) / float(count_LOW_COV + count_GOOD_COV)
	except ZeroDivisionError:
                        percent_GOOD_COV = 0


	if num_SNPs == 0 and percent_LOW_COV >= COV_cutoff:
		RESULT = 'LOW_COV ' + str(percent_LOW_COV)
		count_LOW_COVERAGE += 1
	elif num_SNPs == 0 and percent_LOW_COV < COV_cutoff:
                RESULT = 'NO_SNP ' + str(percent_GOOD_COV)
                count_NO_SNP += 1
	elif num_SNPs > 0 and RESULT == 'DIFFERENT':
		RESULT = 'DIFFERENT '
		count_DIFFERENT += 1
	elif num_SNPs > 0 and RESULT != 'DIFFERENT':
		RESULT = 'SAME '
		count_SAME += 1
	else:
		RESULT = 'NOIDEA '
		count_NOIDEA += 1

	OUTFILE.write(RESULT + "\t" + str(num_SNPs) + "\n")

###print "count_NODATA",count_NODATA,"\tcount_DIFFERENT",count_DIFFERENT,"\tcount_SAME",count_SAME,"\tcount_NOIDEA",count_NOIDEA
total_GOOD_COV = count_DIFFERENT + count_SAME + count_NO_SNP
total = total_GOOD_COV + count_LOW_COVERAGE

try:
	genome_coverage = float(total_GOOD_COV) / float(total) * 100
except ZeroDivisionError:
	genome_coverage = 0

#print total
try:
	percent_identical = float(count_SAME + count_NO_SNP)/float(total_GOOD_COV) * 100
except ZeroDivisionError:
	percent_identical = 0
#print percent
string = str(int(round(genome_coverage,0))) + ':' + str(int(round(percent_identical,0))) + ':' + str(total) + ':' + str(total_GOOD_COV) + ':' + str(count_SAME) +':' + str(count_DIFFERENT) +':' + str(count_NO_SNP) + ':' + str(count_SAME_SNP) + ':' + str(count_DIFFERENT_SNP_01) + ':' + str(count_DIFFERENT_SNP_10)
print string


OUTFILE.close()
INFILE.close()





