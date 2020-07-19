#!/usr/bin/bash
#SBATCH -p batch -N 1 -n 4 --mem 2gb --out logs/download.log
module unload perl
module load parallel
module load sratoolkit
mkdir -p fastq
if [ ! -s fastq/SRR5988742_1.fastq.gz ]; then
	parallel -j 4 fastq-dump --split-files -O fastq --gzip {} ::: $(cat lib/SRP116545.txt)
fi
mkdir -p genome
pushd genome
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/genbank/fungi/Batrachochytrium_dendrobatidis/latest_assembly_versions/GCA_000149865.1_BD_JEL423/GCA_000149865.1_BD_JEL423_genomic.gff.gz
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/genbank/fungi/Batrachochytrium_dendrobatidis/latest_assembly_versions/GCA_000149865.1_BD_JEL423/GCA_000149865.1_BD_JEL423_genomic.gtf.gz
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/genbank/fungi/Batrachochytrium_dendrobatidis/latest_assembly_versions/GCA_000149865.1_BD_JEL423/GCA_000149865.1_BD_JEL423_genomic.fna.gz

pigz -d *.gz
cat GCA_000149865.1_BD_JEL423_genomic.fna assembled_TF5a1.fa > JEL423_w_virus.fasta
module load hmmer/3
module load samtools
esl-sfetch --index JEL423_w_virus.fasta
samtools faidx JEL423_w_virus.fasta
module load STAR

mkdir -p STAR_index
STAR --runMode genomeGenerate --runThreadN 16 --genomeFastaFiles $(realpath JEL423_w_virus.fasta) --genomeDir $(realpath STAR_index) --sjdbGTFfile $(realpath GCA_000149865.1_BD_JEL423_genomic.gtf) --sjdbOverhang 99
