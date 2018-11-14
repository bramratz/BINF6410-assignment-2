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
* [bwa](https://sourceforge.net/projects/bio-bwa/files/latest/download)

**4. Example installation of a tool**

  **a.** Untar Samtools, HTSlib, and BCFtools using the following command:

  `tar -vxjf htslib-1.9.tar.bz2`


  **b.** Then we run the following command which gets the specific system you are using ready for building the program by ensuring all dependencies are present:

  `./configure --prefix=path/to/installation/destination/`

  **c.** Next we want to build the software using the steps outlined in the makefile included in the download by running:

  `make`

  **d.** Laslty to install the software we run the following command:

  `make install`

  * It is important to note that if an error concerning permissions is encountered, you may possibly need to use `sudo` at the beggning of     the command. Some tools only need `./configure` or `make` to be installed. 

  To use the tools globally without having to specify the path each time - add the path of the tool to the PATH environment variable. Access   and edit the PATH variable at the end of the .bashrc file by running the following commands:

  ```
  cd

  nano .bashrc

  export PATH=path/to/tool/installation/directory/:$PATH
  ```

  * if you're using a mac the .bashrc file may not exist and you will have to [create a .bash_profile](https://medium.com/@alohaglenn/programming-lifehack-creating-a-bash-profile-56166dbd341c).

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



