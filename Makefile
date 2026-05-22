.PHONY: all clean

RSCRIPT ?= Rscript

all: paper/paper.pdf

temp/analysis_data.rds output/tables/data_summary.tex: input/pension.rda code/preprocess.R
	"$(RSCRIPT)" code/preprocess.R

output/tables/main_result.tex: temp/analysis_data.rds code/analysis.R
	"$(RSCRIPT)" code/analysis.R

paper/paper.pdf: paper/paper.tex paper/references.bib output/tables/main_result.tex output/tables/data_summary.tex
	cd paper && pdflatex paper.tex
	cd paper && bibtex paper
	cd paper && pdflatex paper.tex
	cd paper && pdflatex paper.tex

clean:
	rm -rf temp/*
	rm -f output/tables/*.tex
	rm -f paper/*.aux paper/*.log paper/*.out paper/*.toc paper/*.bbl paper/*.blg paper/*.synctex.gz paper/paper.pdf
