#!/bin/bash

# Script is written as PBS array jobs

# Packages required for ChIP-seq
# Install packages into a conda environment
# trim-galore/0.6.7
# cutadapt/3.7
# fastqc/0.11.9
# multiqc/1.12
# bowtie2/2.4.4
# samtools/1.14
# bedtools/2.30.0
# macs2/2.2.7.1
# deeptools/3.5.1

base=$(ls -d C0* | head -n $PBS_ARRAY_INDEX | tail -n 1)

cd ./${base}

# First run fastqc and multiqc
mkdir ${base}_pretrim_fastqc
fastqc -d ./ -o ${base}_pretrim_fastqc/ ${base}_1.fq.gz ${base}_2.fq.gz
mkdir ${base}_pretrim_multiqc
multiqc -o ${base}_pretrim_multiqc/ ${base}_pretrim_fastqc/

# Run trim_galore to remove adaptors from data
trim_galore --gzip --paired ${base}_1.fq.gz ${base}_2.fq.gz
mkdir ${base}_trimmed_fastqc
fastqc -d ./ -o ${base}_trimmed_fastqc/ ${base}_1_val_1.fq.gz ${base}_2_val_2.fq.gz
mkdir ${base}_trimmed_multiqc
multiqc -o ${base}_trimmed_multiqc/ ${base}_trimmed_fastqc/

# Run Bowtie2 to get alignment of reads to hg38
bowtie2 -p 4 --no-unal -x ~/Homo_sapiens_hg38/Bowtie2Index/hg38 -1 ${base}_1_val_1.fq.gz -2 ${base}_2_val_2.fq.gz -S ${base}.sam

# Convert sam to bam
samtools view  -S -b ${base}.sam > ${base}.bam

# Run samtools to sort data and remove duplicates
samtools fixmate -m ${base}.bam ${base}-fixmate.bam
samtools sort -o ${base}-sorted.bam ${base}-fixmate.bam
samtools markdup -r ${base}-sorted.bam ${base}-dedup.bam
samtools collate -o ${base}-col.bam ${base}-dedup.bam ${base}_tmp

# Remove intermediate files
rm ${base}.sam
rm ${base}-fixmate.bam
rm ${base}-sorted.bam
rm ${base}-dedup.bam

# Final -col.bam file needs to be sorted and indexed again with samtools for downstream use with deeptools and other tools
# Final two -col-sort.bam and -col-sort.bam.bai are used in other tools. DO NOT DELETE THESE FILES!!

samtools sort -o ${base}-col-sort.bam ${base}-col.bam
samtools index -b ${base}-col-sort.bam ${base}-col-sort.bam.bai

# Convert bam file into bigwig file format for view on a genome browser
bamCoverage -b ${base}-col-sort.bam -o ${base}_RPKM.bw \
        -p 4 \
        --normalizeUsing RPKM \
        --effectiveGenomeSize 2913022398 \
        --extendReads

# For the mouse data, use the mouse genome and respective bowtie2 index. 
# Change the effectiveGenomeSize to 2654621783
