# Makefile for Project
# This Makfile is for building different documents (artifacts) automatically
# Usage:
# make ARG=[PH|DOC] <target>
# targets: all, images, cleansoft, clean4git, cleanall


# Artifacts
VALID_ARGS := PH DOC

## ARG=PH 
PH-IMG=../content/pflichtenheft/images
PH-MAIN=../content/pflichtenheft/pflichtenheft

## ARG=DOC
DOC-MAIN=./../content/docs-as-pdf/docs
#TEMPLATE
DOC-TEMP=./tdocs.tex
DOC-IMG=./../content/mkdocs/docs/images


# General
## check cmd call
ifeq ($(strip $(MAKECMDGOALS)),)
$(error Kein Ziel angegeben. Beispiel: make all ARG=LH)
endif

ifeq ($(strip $(ARG)),)
$(error Kein ARG angegeben. Beispiel: make all ARG=LH)
endif

ifneq ($(filter $(ARG),$(VALID_ARGS)),$(ARG))
$(error Ungültiges ARG: $(ARG))
endif

## Def core vars
IMG  := $($(ARG)-IMG)
MAIN := $($(ARG)-MAIN)
TEMPLATE := $($(ARG)-TEMP)

## check IMG var
ifeq ($(strip $(IMG)),)
$(error Kein IMG für ARG=$(ARG) definiert)
endif

PUML=$(wildcard $(IMG)/*.puml)
DOT=$(wildcard $(IMG)/*.dot) $(wildcard $(IMG)/*.gv)

PUML_SVG=$(PUML:.puml=.svg)  # diese Art von Regel auch beim Löschen verwenden
PUML_PNG=$(PUML:.puml=.png)
DOT_SVG=$(DOT:.dot=.svg)
DOT_SVG+=$(DOT:.gv=.svg)

BUILD_SVG=$(PUML_SVG) $(DOT_SVG)

# Add Images not made out of puml (dont clean)
ORIG_SVG=$(filter-out $(BUILD_SVG), $(wildcard $(IMG)/*.svg))

# PDFs from all SVG types
ALL_PDF=$(BUILD_SVG:.svg=.pdf) $(ORIG_SVG:.svg=.pdf)

# Targets -----------------------------------------

.PHONY: all clean images cleanfull error

## ALL
ifneq ($(filter PH, $(ARG)),)
all: images latex # for artifacs coded in latex
else  # DOC
all: images pandoc latex # Full-Stack with panruby
endif

## CLEANING
ifneq ($(filter PH, $(ARG)),)
### target: CLEANSOFT
cleansoft: cimpng ctemp
	rm -f "$(shell dirname $(MAIN))"/Abschnitte/*.aux
### target: CLEAN4GIT
clean4git: cleansoft cimpdf cpdfd
### target: CLEANALL
cleanall: clean4git cimsvg
else # ONLY FOR ERB-Workflow
### target: CLEANSOFT
cleansoft: cimpng ctemp
### target: CLEAN4GIT
clean4git: cleansoft cimpdf cpdfd
### target: CLEANALL
cleanall: clean4git cimsvg ctex
endif

# PRIVATE -----------------------------------------
## clean IMAGES -----------------------------------
cimpng:
	rm -f $(PUML_PNG)
cimsvg:
	rm -f $(BUILD_SVG)
cimpdf:
	rm -f $(ALL_PDF)

## build IMAGES -----------------------------------
images: $(BUILD_SVG) $(PUML_PNG) $(ALL_PDF)

### PlantUML: .puml -> .svg + .png
$(IMG)/%.svg $(IMG)/%.png: $(IMG)/%.puml
	java -jar plantuml.jar -tsvg "$<"
	java -jar plantuml.jar -tpng "$<"

### DOT/GV: .dot -> .svg
$(IMG)/%.svg: $(IMG)/%.dot
	dot -Tsvg -o "$@" "$<"

### DOT/GV: .gv -> .svg
$(IMG)/%.svg: $(IMG)/%.gv
	dot -Tsvg -o "$@" "$<"

### SVG -> PDF
$(IMG)/%.pdf: $(IMG)/%.svg
	inkscape --export-area-drawing --batch-process --export-type=pdf --export-filename="$@" "$<"


## clean CODE --------------------------------------
### clean temps and logs
ctemp:
	rm -f "$(shell dirname $(MAIN))"/*.tmp
	latexmk -c -outdir="$(shell dirname $(MAIN))" "$(MAIN).tex"
	rm -f "$(shell dirname $(MAIN))"/*.fls
	
### clean pdf-document
cpdfd:
	rm -f "$(shell dirname $(MAIN))"/*.pdf

### clean tex-document
ctex:
	rm -f "$(shell dirname $(MAIN))"/*.tex

## build CODE --------------------------------------
### LATEX
latex:
	latexmk -lualatex -f -outdir="$(shell dirname $(MAIN))" "$(MAIN).tex"
### PANRUBY (latex)
pandoc:
	ruby panruby.rb latex "$(MAIN)" "$(TEMPLATE)" 
