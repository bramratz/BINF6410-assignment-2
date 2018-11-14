# BINF6410-assignment-2
### Possible names: FaQ2Var (fastq to variant calling), FaBaSa-var [(Fa)stq, (Ba)m, (Sa)m], VCF-gen (generator), VCF-ninja, VarFlow, 2Fast2Variant, FaBSVar-pipe, VariantPlumber (cause its a pipe LOL)

## About

[name] is a pipeline designed to be used with fastq type files containing genomic information which returns a variant calling formart (VCF) file. However, the following intermediary file types may be used as well:

* .BAM
* .SAM
* .VCF

## Requirements

### 1. Your system should have a version of python 3 installed

[Download from Python's homepage](https://www.python.org/downloads/)

or excute the following:

`sudo apt-get install python3`

### 2. Installation of these Debian packages is required as they are dependecies of some tools and function as pipeline optimizers.

`sudo apt-get install libbz2-dev`

`sudo apt-get install zlib1g-dev`

`sudo apt-get install liblzma-dev`

`sudo apt-get install libncurses5-dev`

`sudo apt-get install libncursesw5-dev`

### 3. The following tools are used in the pipeline:

* [sickle](https://github.com/najoshi/sickle/archive/v1.33.tar.gz)
* [sabre](https://github.com/najoshi/sabre/archive/master.zip)
* [SamTools](https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2)
* [HTSlib](https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2)
* [BCFtools](https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2)
* [bwa](https://sourceforge.net/projects/bio-bwa/files/latest/download)

### 4. Example installation of a tool

- Untar Samtools, HTSlib, and BCFtools using the following command:

  `tar -vxjf htslib-1.9.tar.bz2`


- Then we run the following command which gets the specific system you are using ready for building the program by ensuring all dependencies are present:

  `./configure --prefix=path/to/installation/destination/`

- Next we want to build the software using the steps outlined in the makefile included in the download by running:

  `make`

- Laslty to install the software we run the following command:

  `make install`

  * It is important to note that if an error concerning permissions is encountered, you may possibly need to use `sudo` at the beggning of     the command. Some tools only need `./configure` or `make` to be installed. 

- To use the tools globally without having to specify the path each time - add the path of the tool to the PATH environment variable. Access   and edit the PATH variable at the end of the .bashrc file by running the following commands:

  ```
  cd

  nano .bashrc

  export PATH=path/to/tool/installation/directory/:$PATH
  ```

  * if you're using a mac the .bashrc file may not exist and you will have to [create a .bash_profile](https://medium.com/@alohaglenn/programming-lifehack-creating-a-bash-profile-56166dbd341c).

## Usage

### 1. User file input

On start up the program will ask the user for input information and create a working directory as well as required subdirectories. To use the program you must specify the path to barcode and fastq files with `.txt` and `.fastq` extensions, respectively. A reference genome must also be specified but there is no one type that is must be.

### 2. FastQC

A FastQC menu will prompt you to perform the test, see the report, skip this step entirely. If you choose to generate a FastQC report - it will be viewable as an HTML file.

### 3. Demultiplexing

The program will now ask the user to enter the command `sabre`. The program stores this information as a variable. Sabre will demultiplex the NGS data, this requires the dna barcode and fastq files. The output of this step will remain a fastq file.

### 4. Read trimming

This step of the program will ask the user to type the `sickle` command to later use as a variable as it did in the previous step. Sickle will trim the reads and cut apdapter sequences from the NGS sequencing data. At the moment only single end data is processed.

### 5. Alignment



