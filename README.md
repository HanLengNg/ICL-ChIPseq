# ICL-ChIPseq
A bash script to generate bam and bigwig files for ChIPseq paired-end fastq files

# Main information
The script is written to run on a PBS cluster that will submit multiple jobs in parallel for each sample

Create a conda environment containing the following packages:
- trim-galore/0.6.7
- cutadapt/3.7
- fastqc/0.11.9
- multiqc/1.12
- bowtie2/2.4.4
- samtools/1.14
- bedtools/2.30.0
- deeptools/3.5.1

Please create subdirectories to store each sample paired-end Illumina fastq files.

Ensure that the name of the subdirectories are the same name as the Illumina fastq files, i.e. C001/C001_1.fq.gz & C001/C001_2.fq.gz

All files generated from the analyses are stored in the same subdirectories where the Illumina fastq files are kept.
