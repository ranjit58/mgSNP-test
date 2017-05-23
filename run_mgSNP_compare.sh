#!/bin/bash
### Import global variables ###
source mgSNP.config.txt
###

parallel -j $THREAD5 "bash {} " ::: $COMPARE/*/*.job
