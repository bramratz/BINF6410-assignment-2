#!/bin/bash

#Who is using this pipeline
echo Hello, who am I talking to?
read USER_NAME
echo "Hello $USER_NAME – It’s nice to meet you!"

#first creating a usage function that will outline what arguments to enter if nothing is entered
#this serves as an error mesage and exits the program so to proceed have to have the correct data entered
usage () {
  echo "Usage: $0 [-b <barcode fil>] [-f <fastq file>] [-r <reference genome>]" 1>&2; exit 1;
}

#this uses getopt to provide the user with arguments to input data to the pipeline
#if at any step data is not entered into an argument, an error message will be show and will exit the pipe
while getopts ":b:f:r:" o; do
  case "${o}" in
    b )
      b=${OPTARG}
      if [[ -z "${b}" ]]
        then
          echo -en "the barcode file does not exist"
          usage
      fi
      ;;
    f )
      f=${OPTARG}
      if [[ -z "${f}" ]]
        then
          echo -en "the fastq file does not exist"
          usage
      fi
      ;;
    r )
      r=${OPTARG}
      if [[ -z "${r}" ]]
        then
          echo -en "the reference genome file does not exist"
          usage
      fi
      ;;
    * )
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${b}" ] || [ -z "${f}" ] || [ -z "${r}" ]; then
  usage
fi

echo "b = ${b}"
echo "f = ${f}"
echo "r = ${r}"

echo ===================================
#making a directory to be our new working directory for this session
echo ===================================

#make parent directory variant_calling
echo "$USER_NAME I am making a working directory for this pipeline"

mkdir -pv variant_calling

#now copy
cp $BARCODES variant_calling
cp $RAW_FASTQ variant_calling
cp $REF variant_calling

#export these variables
export $BARCODES
export $RAW_FASTQ
export $REF

#move to variant_calling, this will be our main WD for this pipeline
echo "$USER_NAME moving you to variant_calling directory"

cd variant_calling

#print working directory
pwd

#make directories for our ref genome and fastq file(s)
echo "$USER_NAME making some directories for your data"

mkdir -pv raw/ref_genome
mkdir -pv raw/fastq_files
mkdir -pv raw/barcodes

mv $BARCODES raw/barcodes
mv $RAW_FASTQ raw/fastq_files
mv $REF raw/ref_genome

echo =================================
#Use FastQC program to analyze the quality of the reads
echo =================================

#make a simple press_enter function
press_enter () {
  echo -en "\nPress Enter to continue"
}

#asking the user if they would like to preform a FastQC analysis on their data
#so what this thing does is print out a menue with options, if the user clicks 1 then FastQC will be preformed
#and they will be prompted with another question asking them if they'd like to see the results of the test
#if yes the program open up another window with the results if no brings them back to the working directory.
#if at the beginning of all this they choose 0, then they get to skip preforming a fastqc
selection=
until [ "$selection" = "0" ]; do
  echo "
  PROGRAM MENU
  1 - Preform FastQC

  0 - return to current working directory
  "

  echo -n "Enter selection: "
  read selection
  echo ""
  case $selection in
    1 )
      echo "Enter path to FastQC on your computer: "
      read -r FastQC
      echo ""
      TOOL_FASTQC=$FastQC
      echo "Running FastQC"
      $TOOL_FASTQC ${f} #raw/fastq_files/$FASTQ_RAW
      echo -en "Done \nWould you like to view the summary? (open another window)"
      read -p "[y/n]: " choice
      case "$choice" in
        y|Y )
          xdg-open *.html #raw/fastq_files/*.html
          press_enter
          ;;
        n|N )
          echo "$USER_NAME you are returning to variant_calling directory"
          cd variant_calling
          press_enter
          ;;
        * )
          echo "please enter y or n"
          press_enter
      esac
      ;;
    0 )
      echo "$USER_NAME you are returning to variant_calling directory"
      cd variant_calling
      press_enter
      ;;
    * )
    echo "Please enter 1 or 0"
    press_enter
  esac
done

echo =================================
#use Sabre for demultiplexing
echo =================================

#ask the user for the path to sabre
echo "$USER_NAME please enter the command for sabre, going to make it into a variable: "
read sabre
  TOOL_SABRE=$sabre

#make directory for the results
mkdir -pv raw/fastq_sabre

#run sabre
echo "running sabre"

#make some variables
input_fastq=raw/fastq_files/*.fastq
input_barcode=raw/barcodes/*.txt
output_sabre=raw/fastq_sabre/SABRE_DATA.sabre_fq

#run sabre
$TOOL_SABRE se -f $input_fastq -b $input_barcode -u $output_sabre
#$TOOL_SABRE se -f raw/fastq_files/*.fastq -b raw/barcodes/*.txt -u SABRE_DATA.fastq

echo "sabre complete"

echo ==================================
#Use sickle program to trim fastq files
echo ==================================


#First have to ask the user to find the sickle program on their computer and provide the path
echo "$USER_NAME please enter the command for sickle, making it into a variable: "
read sickle
  TOOL_SICKLE=$sickle

#make a directory to store the trimmed reads from sickle
mkdir -pv raw/fastq_trimmed

#Run the sickle program with the fastq data
echo "running sickle"

for FASTQ in "raw/fastq_sabre/*.sabre_fq"
  do
    NAME=$( basename $FASTQ .sabre_fq ) #extracts the name of the file without the path and the .fastq extention and assigns it to the variable name
    echo "working with $NAME"

    #create some variables to make this less confusing

    FASTQ=raw/fastq_sabre/$NAME\.sabre_fq
    TRIMMED=raw/fastq_trimmed/$NAME\.trimmed_fq

    #data is all staged now lets run sickle

    $TOOL_SICKLE se -f $FASTQ -t illumina -o $TRIMMED

done

echo "sickle complete"

echo ================================
#Align reads to reference genome BWA
echo ================================

#To start we have to be in the main directory variant_calling
cd variant_calling

#need to load paths for BWA and samtools
echo "$USER_NAME enter the path to BWA on your computer, making it into a variable: "
read bwa
  TOOL_BWA=$bwa

echo "$USER_NAME enter the path to samtools on your computer, making it into a variable: "
read samtools
  TOOL_SAMTOOLS=$samtools

#remember that we assigned our reference genome to the variable $REF, but want to have a variable that includes the path to this to make it easier
WORKING_REF=raw/ref_genome/$REF

#now need to index our reference genome for bwa and samtools
$TOOL_BWA index $WORKING_REF

$TOOL_SAMTOOLS faidx $WORKING_REF

#now lets create some output paths for intermediate and final result files
mkdir -pv results/sai
mkdir -pv results/sam
mkdir -pv results/bam
mkdir -pv results/bcf
mkdir -pv results/vcf

#now going to create a for loop to run the variant calling workflow on however many fastq files we have
#remember the files we are using are in the 'trimmed reads' directory and are called FASTQ_TRIMMED.fq
#this should be able to handle as many files as possible

for reads in raw/fastq_trimmed/*.trimmed_fq
  do
    NAME=$(basename $reads .trimmed_fq) #extracts the name of the file without the path and the .fq extention and assigns it to the variable name
    echo "working with $NAME"

      echo "assign file names to variables to make this less comfusing"

      FQ=raw/fastq_trimmed/$NAME\.trimmed_fq
      SAI=results/sai/$NAME\_aligned.sai
      SAM=results/sam/$NAME\_aligned.sam
      BAM=results/bam/$NAME\_aligned.bam
      SORTED_BAM=results/bam/$NAME\_aligned_sorted.bam
      COUNT_BCF=results/bcf/$NAME\_raw.bcf
      FINAL_VCF=results/bcf/$NAME\.final_bcf
      
      #data can now be moved easily with variables
      #align the reads with BWA

      $TOOL_BWA aln $WORKING_REF $FQ > $SAI

      #convert the output to the SAM formate

      $TOOL_BWA samse $WORKING_REF $SAI $FQ > $SAM

      #SAM to BAM

      $TOOL_SAMTOOLS view -S -b -h $SAM > $BAM

      #sort the BAM file - not sure if this is necessary but everything online seems to do it
      #the -f simply ignores upper and lower case for sorting

      $TOOL_SAMTOOLS sort $BAM -o $SORTED_BAM

      #they also index them everywhere online and the command is simple enough so lets do that

      $TOOL_SAMTOOLS index $SORTED_BAM

      #this line counts read coverage using samtools - prof does something similar to this
      #can omit this if we want, b/c the next step is to do SNP calling with bcftools which is part of samtools

      $TOOL_SAMTOOLS mpileup -uf $WORKING_REF $SORTED_BAM > $COUNT_BCF
      
      #use bcftools to get the SNP varient calls
      bcftools call -mv $COUNT_BCF > $FINAL_VCF
      
      #view this variable 
      less $FINAL_VCF

done

#need to remove this before sibmission, it exits the scripts rn because platypusisnt done
exit

#============================
#Platypus default parameters
#============================
#minMapQual
echo "Which parameters would you like to use with PLATYPUS? If you choose <enter> at any point, the default parameter listed [#] will be used"
read -p "minMapQual? [20]" minMQUAL
while [[ -z $minMQUAL ]]; do
  minMQUAL="20"
done
echo "Selected minMapQual: $minMQUAL"
#minBaseQual
read -p "minBaseQual? [10]" minBQUAL
while [[ -z $minBQUAL ]]; do
  minBQUAL="10"
done
echo "Selected minBaseQual: $minBQUAL"
#minGoodQualBases
read -p "minGoodQualBases? [5]" minGQbases
while [[ -z $minGQbases  ]]; do
  minGQbases="5"
done
echo "Selected minGoodQualBases: $minGQbases"
#badReadsThreshold
read -p "badReadsThreshold? [10]" badRthresh
while [[ -z $badRthresh  ]]; do
  badRthresh="10"
done
echo "Selected badReadsThreshold: $badRthresh"
#rmsmqThreshold
read -p "rmsmqThreshold? [20]" rmsmqThresh
while [[ -z $rmsmqThresh ]]; do
  rmsmqThresh="20"
done
echo "Selected rmsmqThreshold: $rmsmqThresh"
#abThreshold
read -p "abThreshold? 0.01" abThresh
while [[ -z $abThresh ]]; do
  abThresh="0.01"
done
echo "Selected abThreshold: $abThresh"
#maxReadLength
read -p "maxReadLength? [250]" maxRL
while [[ -z $maxRL ]]; do
  maxRL="250"
done
echo "Selected maxReadLength: $maxRL"
#hapScoreThreshold
read -p "hapScoreThreshold? [20]" hapSthresh
while [[ -z $hapSthresh ]]; do
  hapSthresh="20"
done
echo "Selected hapScoreThreshold: $hapSthresh"
#trimAdapter
read -p "trimAdapter? [0]" trimad
while [[ -z $trimad ]]; do
  trimad="0"
done
echo "Selected trimAdapter: $trimad"
#macGOF
read -p "maxGOF? [20]" maxG
while [[ -z $maxG ]]; do
  maxG="20"
done
echo "Selected macGOF: $maxG"
#minReads
read -p "minReads? [50]" minR
while [[ -z $minR ]]; do
  minR="50"
done
echo "Selected minReads: $minR"
#minFlank
read -p "minFlank? [20]" minF
while [[ -z $minF ]]; do
  minF="20"
done
echo "Selected minFlank: $minF"
#sbThreshold
read -p "sbThreshold? [0.01]" sbThresh
while [[ -z $sbThresh ]]; do
  sbThresh="0.01"
done
echo "Selected sbThreshold: $sbThresh"
#scThreshold
read -p "scThreshold? [0.95]" scThresh
while [[ -z $scThresh ]]; do
  scThresh="0.95"
done
echo "Selected scThreshold: $scThresh"
#filterDuplicates
read -p "filterDuplicates? [0]" filtdup
while [[ -z $filtdup ]]; do
  filtdup="0"
done
echo "Selected filterDuplicates: $filtdup"
#filterVarsByCoverage
read -p "filterVarsByCoverage? [0]" filtvarcov
while [[ -z $filtvarcov ]]; do
  filtvarcov="0"
done
echo "Selected filterVarsByCoverage: $filtvarcov"
#filteredReadsFrac
read -p "filteredReadsFrac? [0.7]" filtrfrac
while [[ -z $filtrfrac ]]; do
  filtrfrac="0.7"
done
echo "Selected filteredReadsFrac: $filtrfrac"
#minVarFreq
read -p "minVarFreq? [0.002]" minvfreq
while [[ -z $minvfreq ]]; do
  minvfreq="0.002"
done
echo "Selected minVarFreq: $minvfreq"
#mergeClusteredVariants
read -p "mergeClusteredVariants? [0]" mergeCvar
while [[ -z $mergeCvar ]]; do
  mergeCvar="0"
done
echo "Selected mergeClusteredVariants: $mergeCvar"
#filterReadsWithUnmappedMates
read -p "filterReadsWithUnmappedMates? [0]" filtnomatch
while [[ -z $filtnomatch ]]; do
  filtnomatch="0"
done
echo "Selected filterReadsWithUnmappedMates: $filtnomatch"


python $PLAT callVariants --bamFiles="$DATA" \
	    --nCPU="$CPU" --minMapQual=$minMQUAL --minBaseQual=$minBQUAL \
	    --minGoodQualBases=$minGQbases --badReadsThreshold=$badRthresh \
	    --rmsmqThreshold=$rmsmqThresh --abThreshold=$abThresh --maxReadLength=$maxRL  --hapScoreThreshold=$hapSthresh \
	    --trimAdapter=$trimad --maxGOF=$maxG \
	    --minReads=$minR --minFlank=$minF \
	    --sbThreshold=$sbThresh --scThreshold=$scThresh --hapScoreThreshold=15 \
	    --filterDuplicates=$filtdup \
	    --filterVarsByCoverage=$filtvarcov --filteredReadsFrac=$filtrfrac --minVarFreq=$minvfreq \
	    --mergeClusteredVariants=$mergeCvar --filterReadsWithUnmappedMates=$filtnomatch \
	    --refFile="$REF" \
	    --logFileName=plat.log \
	    --output="$OUT".vcf======


#============================
#SABRE default parameters
#============================
