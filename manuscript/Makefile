# Build PDFs from every .tex file in this directory.
#
#   make                 Build all PDFs
#   make <name>.pdf      Build a single document (e.g. make main.pdf)
#   make clean           Remove LaTeX auxiliary files (keep PDFs)
#   make distclean       Remove auxiliary files and PDFs

LATEXMK   ?= latexmk
LATEXOPTS ?= -pdf -interaction=nonstopmode -halt-on-error -file-line-error

TEX_SOURCES := $(wildcard *.tex)
PDF_TARGETS := $(TEX_SOURCES:.tex=.pdf)

.PHONY: all clean distclean help
.DEFAULT_GOAL := all

all: $(PDF_TARGETS)

%.pdf: %.tex
	$(LATEXMK) $(LATEXOPTS) $<

clean:
	$(LATEXMK) -c
	rm -f *.aux *.bbl *.bcf *.blg *.fdb_latexmk *.fls *.log *.nav *.out \
	      *.run.xml *.snm *.synctex.gz *.toc *.vrb *Notes.bib

distclean:
	$(LATEXMK) -C
	rm -f $(PDF_TARGETS)

help:
	@echo "Targets:"
	@echo "  all (default)  Build PDFs for all .tex files in this directory"
	@echo "  <name>.pdf     Build a single document, e.g. make main.pdf"
	@echo "  clean          Remove LaTeX auxiliary files (keep PDFs)"
	@echo "  distclean      Remove auxiliary files and PDFs"
