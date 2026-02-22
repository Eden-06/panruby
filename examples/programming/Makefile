ALL=$(wildcard *.md.erb *.sty *.tex images/*.puml images/*.svg)
MAIN=paper
TEMPLATE=tprogramming.tex
PUML=$(wildcard images/*.puml)
SVG=$(wildcard images/*.svg) $(PUML:.puml=.svg)
PDF=$(SVG:.svg=.pdf)

.PHONY: all clean images

all: images pandoc latex

html: images pandoc-html to-html

presi: images beamer latex

.PHONY: clean

clean:
	rm -f *.tmp
	latexmk -c $(MAIN)

images: $(PDF) # $(SVG) $(PUML) add for SVG to PDF and plantUML support
	
## uncomment for plantUML support
# images/%.svg: images/%.puml
# 	java -jar plantuml.jar -tsvg "$<"
# 	java -jar plantuml.jar -tpng "$<"

## uncomment for Conversion of SVG to PDF with Inkscape
# images/%.pdf: images/%.svg
#	inkscape --export-area-drawing --batch-process --export-type=pdf --export-filename="$@" "$<"

pandoc:
	ruby panruby.rb latex "$(MAIN)" "$(TEMPLATE)"

pandoc-html:
	ruby panruby.rb html "$(MAIN)" "$(TEMPLATE)"

to-html: 
	pandoc -s "$(MAIN).tmp" -f markdown+yaml_metadata_block+grid_tables+table_captions+smart -t html -o "$(MAIN).html" --listings --mathjax
	sed -i 's/math inline/latex/g' "$(MAIN).html"
	sed -i 's/math display/latex/g' "$(MAIN).html"
	sed -i 's/>[\](/>/g' "$(MAIN).html"
	sed -i 's/>\\\[/>/g' "$(MAIN).html"
	sed -i 's/\\)</</g' "$(MAIN).html"	
	sed -i 's/\\\]</</g' "$(MAIN).html"	

latex:
	latexmk -lualatex -f "$(MAIN).tex"

doc:
	pandoc -s "$(MAIN).tmp" -f markdown+yaml_metadata_block+grid_tables+table_captions+smart -t html -o "$(MAIN).html" --listings --webtex
	pandoc -s "$(MAIN).html" -t docx -o "$(MAIN).docx"
