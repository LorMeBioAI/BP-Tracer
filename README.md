# BP-Tracer: Species tracing of biopollutome

- [[#Introduction|Introduction]]
	- [[#Introduction#About the biopollutome|About the biopollutome]]
	- [[#Introduction#Pipeline workflow|Pipeline workflow]]
- [[#Installation|Installation]]
	- [[#Installation#Installing with Conda|Installing with Conda]]
	- [[#Installation#Manual Installation|Manual Installation]]
- [[#Usage|Usage]]
	- [[#Usage#1. Pathogenic bacteria detection|1. Pathogenic bacteria detection]]
	- [[#Usage#2. hamrful gene analysis|2. hamrful gene analysis]]
		- [[#2. hamrful gene analysis#Step 1|Step 1]]
		- [[#2. hamrful gene analysis#Step 2|Step 2]]
		- [[#2. hamrful gene analysis#Note|Note]]
	- [[#Usage#2. HGT|2. HGT]]
- [[#License|License]]
- [[#Contact|Contact]]

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
![biopollotome](BP-Tracer/attachment/biopolltome.png)
### Pipeline workflow

![workflow](BP-Tracer/attachment/workflow.png)

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

### Download supporting databases

- Please run `download.sh` to download and extract larger data files that cannot be hosted in github.

BP-Tracer comes with a detailed user manual located in the `doc/` directory. Please read the manual before running the pipeline.

## Usage

### 1. Pathogenic bacteria detection

To begin the analysis, run the following command:

```bash
perl BP-Tracer_Tax.pl -input /filename/clean.fq.list
```
The `-input` parameter specifies a list of clean data files and their corresponding sample IDs. For example:
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

BP-Tracer HGT is an extension of BP-Tracer that utilizes WAAFLE to analyze horizontal gene transfer (HGT) events in metagenomic assembly sequences.

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
