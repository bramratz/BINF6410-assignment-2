# BINF6410-assignment-2
### Possible names: FaQ2Var (fastq to variant calling), FaBaSa-var [(Fa)stq, (Ba)m, (Sa)m], VCF-gen (generator), VCF-ninja, VarFlow, 2Fast2Variant, FaBSVar-pipe, VariantPlumber (cause its a pipe LOL)

## About

[name] is a pipeline designed to be used with fastq type files containing genomic information which returns a variant calling formart (VCF) file. However, the following intermediary file types may be used as well:

* .BAM
* .SAM
* .VCF

## Requirements

**1. Your system should have a version of python 3 installed**

[Downloads on Python's homepage](https://www.python.org/downloads/)

or if youre using a Debian Linux distributon - excute the following:

`sudo apt-get install python3`

**2. Installation of these Debian packages is required as they are dependecies of some tools and function as pipeline optimizers.**

`sudo apt-get install libbz2-dev`

`sudo apt-get install zlib1g-dev`

`sudo apt-get install liblzma-dev`

`sudo apt-get install libncurses5-dev`

`sudo apt-get install libncursesw5-dev`

**3. The following tools are used in the pipeline:**

* [sickle](https://github.com/najoshi/sickle/archive/v1.33.tar.gz)
* [sabre](https://github.com/najoshi/sabre/archive/master.zip)
* [SamTools](https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2)
* [HTSlib](https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2)
* [BCFtools](https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2)
* bwa (is downloaded alongside SamTools)

**4. Example installation of a tool**

```
./configure --prefix=path/to/installation/destination/

make

make install
```

To use the tools globally without having to specify the path each time - add the path of the tool to the PATH environment variable.

Accessing and editing the PATH variable through .bashrc:

```
cd

nano .bashrc

export PATH=path/to/tool/installation/directory/:$PATH
```

## Usage

**1. User files and input**

On start up the program will ask the user for input information and create a working directory as well as required subdirectories.
###### note to self: change this if the url download works
Once notified of folder creation, download your reference genome and place it in /raw/ref_genome folder. Follow the same instructions for the fastq data you wish to use. The user should also have a barcode file that is required for sabre.

**2. FastQC**

A FastQC menu will prompt you to perform the test, see the report, skip this step entirely. If you choose to generate a FastQC report - it will be viewable as an HTML file.

**3. Demultiplexing**

Sabre will demultiplex the NGS data. This requires a dna barcode file and the path to the file.

**4. Read trimming**

Sickle will trim the reads and cut apdapter sequences from the NGS sequencing. The program will prompt the user for the path to Sickle.

**5. Alignment**



