# Test Programming Template

An example to use panruby and Pandoc to create a paper for Springer's [Lecture Notes in Computer Science (LNCS)](https://www.springer.com/gp/computer-science/lncs/conference-proceedings-guidelines) 
using their [LaTeX2e](https://resource-cms.springernature.com/springer-cms/rest/v1/content/19238648/data/v8) template.

The template comes with a simple Makefile, yet does not include the template files `llncs.cls` and `splncs04.bst`.

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

1. Download the latest Version of the LNCS template
2. Copy the `llncs.cls` and `splncs04.bst` files in the `examples/lncs` folder
3. Change the directory into the `examples/lncs` folder

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

If, like me, you want to include PlantUML diagrams. Download the current `plantuml.jar` file and put it into the `examples/lncs` folder. Moreover, uncomment the follwoing lines in the `Makefile`. This will ensure that, whenever the PlantUML files change, their images are regenerated automatically.

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

* Currently, `biblatex` does not work well with the `splncs04.bst` bibliography style, thus the `style=lncs` is used as a compatible option.
* Labels to figure and table have limited support, thus the script provides the `label(l)` and `ref(l,alt)` command.
* Currently, `pandoc` generate longtables that do not work with the LNCS format ([see](https://github.com/jgm/pandoc/issues/1023)). A workaround is to input a latex table from a file. The ´nature-of-roles.md.erb´ shows an example.