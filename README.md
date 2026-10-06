# Genome and transcriptome assembly of *Arabidopsis thaliana* Pyl-1

Repository for the Genome and Transcriptome Assembly course

The genome of the *A. thaliana* accession **Pyl-1** was assembled from PacBio HiFi reads with three assemblers (**Flye**, **Hifiasm** and **LJA**), and a transcriptome of the accession **Sha** was assembled from Illumina RNA-seq reads with **Trinity**. The assemblies were evaluated with BUSCO, QUAST and Merqury, and compared with each other and with the TAIR10 reference using nucmer and mummerplot.

## Repository structure

```
.
├── config.sh                 # all paths, parameters and software versions
├── run_pipeline.sh           # submits every step to SLURM with job dependencies
├── collect_results.sh        # copies summary files from output_dir/ into results/
├── scripts/
│   ├── 01_qc/                # fastqc.sh, fastp_hifi.sh, fastp_rnaseq.sh
│   ├── 02_assembly/          # flye.sh, hifiasm.sh, lja.sh, trinity.sh
│   ├── 03_evaluation/        # busco.sh, quast_no_ref.sh, quast_ref.sh, meryl_db.sh, merqury.sh
│   └── 04_comparison/        # nucmer_mummerplot.sh
├── results/                  # small summary outputs tracked in Git
│   ├── 03_evaluation/        # busco/, quast/, merqury/
│   └── 04_comparison/        # nucmer/ (dot plots)
```

## Input data

| Data | Description | Accession / source |
| --- | --- | --- |
| Genome reads | Pyl-1, PacBio HiFi | ERR11437347 |
| RNA-seq reads | Sha, Illumina paired end | ERR754081 |
| Reference | *A. thaliana* TAIR10 (Col-0) genome and annotation | Ensembl Plants release 57 |

## Software

All tools were run on the IBU HPC cluster (SLURM) through Apptainer containers, except Trinity, which was loaded as a module.

| Step | Tool | Version |
| --- | --- | --- |
| Read QC | FastQC | 0.12.1 |
| Read QC and trimming | fastp | 0.24.1 |
| Genome assembly | Flye | 2.9.5 |
| Genome assembly | Hifiasm | 0.25.0 |
| Genome assembly | LJA | 0.2 |
| Transcriptome assembly | Trinity | 2.15.1 |
| Gene completeness | BUSCO (lineage `brassicales_odb10`) | 5.7.1 |
| Assembly statistics | QUAST | 5.2.0 |
| k-mer QV and completeness | Merqury and meryl (k = 31) | 1.3 |
| Whole genome alignment and dot plots | MUMmer4 (nucmer, mummerplot) | 4 |

Exact container paths are listed in `config.sh`.

## How to reproduce
```bash
git clone https://github.com/KittykatKai/Assembly_and_annotation.git
cd Assembly_and_annotation
# If not on the IBU cluster, edit the paths in config.sh first
bash run_pipeline.sh          # submits all jobs in the right order
bash collect_results.sh       # once all jobs have finished
```
### Workflow and dependencies

| Step | Scripts | Runs after |
| --- | --- | --- |
| 1. QC | `fastqc.sh`, `fastp_hifi.sh`, `fastp_rnaseq.sh` | nothing |
| 2. Assembly | `flye.sh`, `hifiasm.sh`, `lja.sh`, `trinity.sh` | nothing |
| 3. k-mer database | `meryl_db.sh` | nothing |
| 3. BUSCO | `busco.sh <assembler>` | the matching assembly |
| 3. Merqury | `merqury.sh <assembler>` | the matching assembly and `meryl_db.sh` |
| 3. QUAST | `quast_no_ref.sh`, `quast_ref.sh` | all three genome assemblies |
| 4. Comparison | `nucmer_mummerplot.sh` | all three genome assemblies |

## Author

Callie Sales, University of Bern
