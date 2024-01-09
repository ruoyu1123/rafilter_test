#! /usr/bin/bash

#!/bin/bash

# 检查是否提供了足够的参数
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <align_file> <reference_file> <reads_file>"
    exit 1
fi

# 从命令行参数中获取文件名
sam_file=$1
reference_file=$2
reads_file=$3

# 打印输入文件名
echo "SAM file: $sam_file"
echo "Reference file: $reference_file.fa"
echo "Reads file: $reads_file.fq"

outputref=ref_out2984372.fa

sed -n '1~4s/^@/>/p;2~4p' $reads_file > query.fa  # For fastq
# fasta to fasta with single line sequence
awk '/^>/{print n $1; n = "\n"} !/^>/{printf "%s",$0}' $reference_file > $outputref  # For fasta


jellyfish count -m 21 -s 1G -t 16 -C $reference_file

# for HiFi reads alignments, we recommand use unique kmer.
jellyfish dump -c -U 1 mer_counts.jf > unique.kmer   # HiFi alignment

rm mer_counts.jf

../src/rafilter build -t 16 -q query.fa -r $outputref -o ra_build unique.kmer

../src/rafilter filter --threshold 8 -o ra_result/ -p ra_build/ref.pos ra_build/query.pos $sam_file



