# Test Programming Template

An example to use panruby and Pandoc to create a paper for the [Association for Computing Machinery (ACM)](https://acm.org) 
using their great [acmart](https://github.com/borisveytsman/acmart/) template.

The template comes with a simple Makefile, yet does not include the template files `acmart.cls`

## Usage:
    ~~~
    make
    make pandoc
    make latex
    make clean
    ~~~

## Version:
 1.2.3

## Requirements

* pandoc
* pandoc-citeproc
* Ruby version 3.0.0
* Document encoding UTF-8
* ERB
* make
* PlantUML *(optional)*
* Inkscape 1.1.2+ *(optional)*

## Installation

1. Download the latest Version of the acmart template
2. Copy the `acmart.cls` and `ACM-Reference-Format.bst` files in the `examples/acmart` folder
3. Change the directory into the `examples/acmart` folder

## Files and Folders

| **Files/Folder** | **Description**                             |
|:-----------------|:--------------------------------------------|
| `images/`        | Contains the images used by the paper
| `tables/`        | Contains the tables used in the paper
| `sections/`      | Contains the sections of the paper as `*.md.erb` files.
| `panruby.rb`     | The panruby script.
| `paper.bib`      | The bibliography file used in the paper.
| `paper.md.erb`   | The main file containing the meta data (YAML) and list of sections to be loaded.
| `README.md`      | This file.

## Support of PlantUML Images

If, like me, you want to include PlantUML diagrams. Download the current `plantuml.jar` file and put it into the `examples/acmart` folder. Moreover, uncomment the follwoing lines in the `Makefile`. This will ensure that, whenever the PlantUML files change, their images are regenerated automatically.

```bash
images: $(PDF) $(SVG) $(PUML)

images/%.svg: images/%.puml
 	java -jar plantuml.jar -tsvg "$<"
 	java -jar plantuml.jar -tpng "$<"
```

Additionally, if [Inkscape](https://inkscape.org) is installed on your machine, you can enable the automatic transformation of SVG images to PDF images. To enable this simply uncomment the following lines in the `Makefile`.

```bash
images/%.pdf: images/%.svg
	inkscape --export-area-drawing --batch-process --export-type=pdf --export-filename="$@" "$<"
```

## Known Issues

* Labels to figure and table have limited support, thus the script provides the `label(l)` and `ref(l,alt)` command.
* Currently, `pandoc` generate longtables that do not work with two-column paper formats ([see](https://github.com/jgm/pandoc/issues/1023)). A workaround is to input a latex table from a file. The ´nature-of-roles.md.erb´ shows an example.