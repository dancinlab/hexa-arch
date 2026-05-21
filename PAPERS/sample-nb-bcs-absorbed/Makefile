# Compile main.pdf with bibtex (3-pass cross-ref resolution).
# `make` produces main.pdf; `make clean` removes intermediates.
# `make check` runs the RTSC-claim attestation hook (Stage 2 enforcement,
# constitution.md v1.4.0 R4) — runs automatically as a prerequisite of `all`.

DOC = main
LATEX = pdflatex -interaction=nonstopmode -halt-on-error
BIBTEX = bibtex
CHECK_RTSC = ../_tools/check_rtsc_claim.sh

.PHONY: all check clean distclean

all: check $(DOC).pdf

check:
	@bash $(CHECK_RTSC) .
	@echo "[paper] check_rtsc_claim PASS"

$(DOC).pdf: $(DOC).tex references.bib
	$(LATEX) $(DOC).tex
	$(BIBTEX) $(DOC) || true
	$(LATEX) $(DOC).tex
	$(LATEX) $(DOC).tex
	@echo "[paper] $(DOC).pdf built at $$(date '+%Y-%m-%d %H:%M:%S')"

clean:
	rm -f $(DOC).aux $(DOC).bbl $(DOC).blg $(DOC).log $(DOC).out \
	      $(DOC).toc $(DOC).synctex.gz
	@echo "[paper] intermediates cleaned (PDF preserved)"

distclean: clean
	rm -f $(DOC).pdf
