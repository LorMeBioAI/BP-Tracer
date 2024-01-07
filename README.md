# BP-Tracer: Species tracing of biopollutome
### **New Version of BP-Tracker is currently being updated, Please wait!**

* 1. [Introduction](#Introduction)
	* 1.1. [About the biopollutome](#Aboutthebiopollutome)
	* 1.2. [Pipeline workflow](#Pipelineworkflow)
* 2. [Installation](#Installation)
	* 2.1. [Installing with Conda](#InstallingwithConda)
	* 2.2. [Manual Installation](#ManualInstallation)
	* 2.3. [Software requirements](#Softwarerequirements)
	* 2.4. [Database requirements](#Databaserequirements)
* 3. [Usage](#Usage)
	* 3.1. [1. Pathogenic bacteria detection](#Pathogenicbacteriadetection)
	* 3.2. [2. hamrful gene analysis](#hamrfulgeneanalysis)
		* 3.2.1. [Step 1](#Step1)
		* 3.2.2. [Step 2](#Step2)
		* 3.2.3. [Note](#Note)
	* 3.3. [2. HGT](#HGT)
* 4. [License](#License)
* 5. [Contact](#Contact)

## Introduction

We presented a novel pipeline called BP-Tracer, a metagenomic analysis pipeline that unravels the three main components of biopollutome-associated risk: **1) the presence of pathogenic bacteria, 2) the presence of harmful genes and 3) the spread probability of these harmful genes to pathogens**. 
Analysing the biopollutome, which refers to the pathogenic bacterial hosts of harmful genes, is the core function of the pipeline. This function depends on PGfunc, a species-functional gene database containing information on gene types and their corresponding species hosts, **which was constructed from 14,051 species-level pangenomes** (PG). This database enables users to comprehensively and quantitatively analyse the types and host sources (including pathogenic bacteria) of harmful genes, including ARGs, MGEs, MRGs, and VFs, from multiple perspectives using a large amount of metagenomic read data and generate corresponding profiles of gene types and hosts.

If you are using BP-Tracer in your research, please cite the following paper:
> BP-tracer: A metagenomic pipeline for tracing the multifarious biopollutome
> Yaozhong Zhang & Gaofei Jiang
> 
> *XXXX* (2023)
> doi: [XXXX/XXXX-XXX-XXX-X](https://)
> 


### About the biopollutome
![biopollotome](https://github.com/LorMeBioAI/BP-Tracer/blob/main/attachment/biopolltome.png)
**Components of the Biopollutome and their risks to One Health.** **(a)** The concept of the biopollutome encompasses several categories of harmful genes including antibiotic resistance genes (ARGs), mobile genetic elements (MGEs), metal resistance genes (MRGs), and virulence factors (VFs) potentially transferable to pathogenic bacteria. These genes pose a serious threat by increasing pathogen virulence and resistance to available treatments. **(b)** Major threats posed by the biopollutome. In an ecosystem, the health of humans, animals and plants is interconnected by microbial loops that facilitate the exchange of beneficial microorganisms and pathogens. Harmful genes present in pathogens can enhance the survival and virulence of pathogens affecting humans, animals and plants. Therefore, frequent horizontal gene transfer events in pathogen habitats can further exacerbate the antimicrobial resistance risk of pathogenic bacteria, posing a severe threat to public and environmental health. **(c)** Assessing the biopollutome-associated risk. The risk posed by the biopollutome is a function of three components: *i)* the presence of pathogenic bacteria in the environment, *ii)* the presence of harmful genes, and *iii)* the probability of spread of these harmful genes to pathogens. The BP-tracer allows integrating these three components into an aggregated risk assessment.


### Pipeline workflow

![workflow](https://github.com/LorMeBioAI/BP-Tracer/blob/main/attachment/workflow.png)
**Overview of BP-Tracer.** **(a)** Pangenomes construction. A total of 206,876 genomes were obtained from the Bacteria NCBI RefSeq database to construct the species-level genome clusters. Then, species-level pangenome ORFs were constructed by predicting genes from genome clusters and clustering them at a 95% similarity threshold. (see Methods and Supplementary Tables 1-2). **(b)** Databases and pipeline construction. PGtax, PGfunc, and PGtrans databases were constructed based on the pangenome ORFs. These databases were then integrated into different functional modules, which were used to implement pathogen detection, harmful gene analysis, and horizontal gene transfer (HGT) event detection. The technical route, database, and output results of each module are represented with the same colors: pink, purple, and blue, respectively. **(c)** Pipeline input. BP-Tracer requires metagenomic reads as input to achieve pathogen detection and analysis of gene types and hosts. Contig sequences are required as input to achieve pathogen HGT detection. (d) Pipeline output. Including profiles of pathogenic bacteria and other species, profiles of gene types, subtypes and host species, and a list of HGT events including pathogens.
## Installation
### Installing with Conda

BP-Tracer can be installed using conda. 

```shell
# 1. create a new environment and activate it
conda create -n bp_tracer perl
conda activate bp_tracer

# 2. use the following command to install BP-Tracer
conda install -c bioconda bp-tracer
```

### Manual Installation

BP-Tracer can also be installed manually. To do so, first clone the BP-Tracer repository:

```shell
git clone <https://github.com/LorMeBioAI/BP-Tracer.git>
```

Then, navigate to the BP-Tracer directory and run the installation script:

```shell
bashCopy code
cd BP-Tracer
./install.sh

```

BP-Tracer requires a Unix-like operating system and Perl 5.16 or higher. To install BP-Tracer, simply clone this repository and run the installation script:

```shell
git clone <https://github.com/LorMeBioAI/BP-Tracer.git>
cd BP-Tracer
./install.sh

```

### Software requirements

* python=2.7.18
* blast=2.12.0
* diamond=0.9.24
* bowtie2
* kraken2=2.1.2
* minimap2
* samtools
* waafle=0.1.0

### Database requirements
BP-Tracer requires three supporting databases built from species-level pangenomes
* [PGtax](http://) (98 GB), **a K-mer indexed database** for the kraken2-adapted taxonomic profiling
* [PGfunc](http://) (1GB), **a Species-functional gene database** containing the harmful genes and their reservoir host species information
* [PGtrans](http://) (45GB), **a BLAST-formatted nucleotide sequence database** for HGT (WAAFLE requires)
> Please run `download.sh` to download and extract larger data files that cannot be hosted in github.


## Usage

### 1. Pathogenic bacteria detection

To begin the analysis, run the following command:

```bash
perl BP-Tracer_Tax.pl -input /filename/clean.fq.list
```
The `-input` parameter specifies a clean.fq.list of clean data files and their corresponding sample IDs. (Pleas use the \tab)
For example:
```
T1	/PWD/T1.clean.1.fq.gz	/PWD/T1.clean.2.fq.gz
T2	/PWD/T1.clean.1.fq.gz	/PWD/T2.clean.2.fq.gz
T3	/PWD/T1.clean.1.fq.gz	/PWD/T3.clean.2.fq.gz

```

1. Submit all `S0.1` scripts to obtain all species abundance tables
2. Submit `S0.2.tax.sh` to merge the abundance tables for all samples

### 2. hamrful gene analysis

BP-Tracer is designed to work with raw metagenomic sequencing data. To run the pipeline, use the following command:

#### Step 1

To begin the analysis, run the following command:

```bash
perl BP-Tracer_Gene1.pl -input /filename/clean.fq.list
```

After running the command, a `shell` folder containing analysis scripts will be generated in the `filename` folder. To continue the analysis, enter the `shell` folder and:

1. Submit all `S1.ARG*.sh` 
2. Submit all `S2.MGE.*sh`, `S2.MRG.*sh`, and `S2.VFDB.*sh` 

#### Step 2

After the S1 and S2 scripts have been executed, run the following command:

```bash
perl BP-Tracer_Gene2.pl

```

After running the command, the `S3.*.sh` and `S4.sh` scripts will be updated in the `shell` folder. To continue the analysis, enter the `shell` folder and:

1. Submit all `S3.*.sh` scripts
2. Submit the `S4.sh` script to obtain the ARG, MGE, MRG, and VF profiles

#### Note

If you need to perform host species correction for multiple host organisms, you need obtain the species abundance table before running the `S4.sh` script.

### 2. HGT

BP-Tracer HGT is an extension of BP-Tracer that utilizes WAAFLE( http://huttenhower.sph.harvard.edu/waafle) to analyze horizontal gene transfer (HGT) events in metagenomic assembly sequences.

To use BP-Tracer HGT, run the following command:

```bash
perl BP-Tracer_HGT.pl -input /filename/contig.fq.list
```

The `-input` parameter specifies a list of contig files in FASTQ format. For example:

```
T1	/PWD/T1.contig.fa
T2	/PWD/T1.contig.fa
T3	/PWD/T1.contig.fa
```
After running the command, a `shell` folder containing analysis scripts will be generated in the `filename` folder. To continue the analysis, enter the `shell` folder and:

1. Submit all `HGT*` scripts

---

## License

This project is licensed under the MIT License - see the [LICENSE](https://chat.openai.com/chat/LICENSE) file for details.

## Contact

For any questions or issues regarding BP-Tracer, please contact us at [yaozhongzyz@stu.njau.edu.cn](notion://www.notion.so/yaozhongzyz@stu.njau.edu.cn).
