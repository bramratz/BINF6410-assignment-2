#!/bin/bash

echo =====================================
#Packages to import
echo =====================================

#load modules that we are going to use in this pipeline

module load fastqc

module load sabre

module load Platypus

echo =====================================
#asking for user imput
echo =====================================

#loading required fastqc files
#get users name
echo 'What would you like to be called?'
read usrname

#need user to tell us where the fastq files are and provide the path to them
echo '$usrname what is the path to your fastq file'
read FASTQ
  DATA=$FASTQ
echo

#need path to fastqc
echo '$usrname what is the path to fastqc'
read fastqc
  TOOL_FASTQC=$fastqc
echo

#create directory for results of analysis
mkdir -pv fastqc_results

#copy fastq data there
cp $DATA /fastqc_results

#change the path
cd fastqc_results

#run fastqc on fastq file to check the quiality of the reads in the file and to assess whether or not data trimming needs to be done
./$TOOL_FASTQC $DATA > Fastqc_results.txt
