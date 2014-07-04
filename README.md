# PanRuby

A lightweight ruby front-end for pandoc that allows the usage of ERB-style templates within mutlimarkdown files.

It is a build tool for the transformation of multimarkdown to
various formats based on pandoc. The source file could be either a
standard markdown *(\*.md)* file or a ERB template *(\*.md.erb)*.
This tool is meant to be used with custom templates for scientific
writing.

## Usage:
    ~~~
    build.rb latex|beamer|html [sourcefile] [template] [bibfile]
    build.rb latex|beamer|html [name] [template]
    ~~~

## Version:
 1.2

## Requirements

* Ruby version 1.9.1
* Document encoding UTF-8
* ERB

## Known Issues

* Insecure call to exec
* Addhoc coding style, which needs refactoring
* Missing tests
* Missing contributors
