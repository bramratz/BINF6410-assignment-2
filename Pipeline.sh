#!/bin/bash
==============================
Assignment information
==============================
"""
The goal of this assignment is to develop a pipeline to go from raw sequencing data (fastq) to a Genotype Table (VCF)
Completed by Bram Ratz, Gurkamal Deol, Shalini Suraj, and Ian Lee
"""
echo =====================================
#Packages to import
echo =====================================

#Load modules that we are going to use in this pipeline

module load fastqc

module load sabre

module load Platypus

#Loading required fastqc files
#Get users name
echo 'What would you like to be called?'
read usrname

#Need user to tell us where the fastq files are and provide the path to them
echo '$usrname what is the path to your fastq file'
read FASTQ
  DATA=$FASTQ
echo

#Need path to fastqc
echo '$usrname what is the path to fastqc'
read fastqc
  TOOL_FASTQC=$fastqc
echo

#Create directory for results of analysis
mkdir -pv fastqc_results

#Copy fastq data there
cp $DATA /fastqc_results

#Change the path
cd fastqc_results

#Run fastqc on fastq file to check the quality of the reads in the file and to assess whether or not data trimming needs to be done
./$TOOL_FASTQC $DATA > Fastqc_results.txt
