# hdm 401(k) Replication

This repository is a reproducible replication package for the 401(k) plan participation application in Section 6.3 of Chernozhukov, Hansen, and Spindler (2016), focusing on the ATE and ATET estimates generated from the `pension` dataset in the `hdm` R package.

## Citation

Chernozhukov, Victor, Christian Hansen, and Martin Spindler. 2016. "High-Dimensional Metrics in R." *The R Journal* 8(2):185-199.

## Data Source

The input file `input/pension.rda` is a local copy of the `pension` dataset distributed with the `hdm` R package. The `input/` directory is treated as read-only by the replication workflow.

## Replication Target

The project replicates the paper's Section 6.3 treatment effect estimates:

- ATE estimate: 10180.09, standard error: 1930.68
- ATET estimate: 12628.46, standard error: 2944.43

## Prerequisites

Install R and the required R packages:

```r
install.packages(c("hdm", "xtable"))
```

To build the PDF paper, install a LaTeX distribution with `pdflatex` and `bibtex`. To run the full pipeline with `make`, install GNU Make.

## Reproduction Commands

From the repository root:

```sh
Rscript code/preprocess.R
Rscript code/analysis.R
make
```

Or run the full clean rebuild:

```sh
./run_all.sh
```

## Expected Results

The analysis should reproduce an ATE estimate of approximately 10180.09 with standard error 1930.681, and an ATET estimate of approximately 12628.46 with standard error 2944.434. Generated tables are written to `output/tables/`, and the compiled paper is written to `paper/paper.pdf`.
