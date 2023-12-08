FILENAME=vonLaszewski-cloudmask-related
DIR=mlcommons-cloudmask-activities
UPLOAD=upload

# .PHONY: $(FILENAME).pdf

all: $(FILENAME).pdf

# MAIN LATEXMK RULE

$(FILENAME).pdf: 
	latexmk  -shell-escape -quiet -bibtex $(PREVIEW_CONTINUOUSLY) -f -pdf -pdflatex="pdflatex -synctex=1 -interaction=nonstopmode" -use-make $(FILENAME).tex

.PRECIOUS: %.pdf
.PHONY: watch

watch: PREVIEW_CONTINUOUSLY=-pvc
watch: $(FILENAME).pdf

.PHONY: clean

clean:
	latexmk -C -bibtex
	rm -rf $(FILENAME).spl
	rm -f *_bibertool.bib
	rm -f *.ttt
	rm -f *.blg
	rm -f comment.cut
	rm -rf *~

regular: clean
	pdflatex $(FILENAME)
	bibtex $(FILENAME)
	pdflatex $(FILENAME)
	pdflatex $(FILENAME)

biber:
	@echo
	biber -V --tool cloud-scheduling.bib | fgrep -v INFO
	@echo
	biber -V --tool cloud-scheduling_bibertool.bib | fgrep -v INFO
	@echo
	biber -V --tool strings.bib | fgrep -v INFO
	@echo
	biber -V --tool vonlaszewski.bib | fgrep -v INFO
	@make -f Makefile clean

zip: clean regular
	rm -rf *.zip
	rm -rf $(UPLOAD)
	mkdir -p $(UPLOAD)
	cp $(FILENAME).* $(UPLOAD)
	cp *.tex $(UPLOAD)
	cp *.bib $(UPLOAD)
	cp -r images $(UPLOAD)
	cd upload; zip -x "*/.DS*" "*/*.git*" "*/*bin*" "*/*zip" "*/*.md" "*/Makefile" "*/*.log" "*/*.aux" "*/*.blg" "$(FILENAME).pdf" -r ../$(FILENAME).zip .

flatzip: clean
	zip -x "*.git*" "*bin*" "*zip" "*.md" "Makefile" -r $(FILENAME).zip .

publish:
	cp $(FILENAME).pdf ../../laszewski/papers/
	cd ../../laszewski/papers; git pull
	cd ../../laszewski/papers; git add $(FILENAME).pdf
	cd ../../laszewski/papers; git commit -m "update $(FILENAME)" $(FILENAME).pdf
	cd ../../laszewski/papers; git push

p: 
	pdflatex -shell-escape $(FILENAME)

latex:
	pdflatex $(FILENAME)
	bibtex $(FILENAME)
	pdflatex $(FILENAME)
	pdflatex $(FILENAME)



word:
	cp vonLaszewski-cloudmesh-cc.bbl report.bbl
	latex2rtf report.tex

flatten:
	bin/latex-flatten.py $(FILENAME).tex report.tex
