# PanRuby

A lightweight ruby front-end for pandoc that allows the usage of ERB-style templates within mutlimarkdown files.

It is a build tool for the transformation of multimarkdown to
various formats based on pandoc. The source file could be either a
standard markdown *(\*.md)* file or a ERB template *(\*.md.erb)*.
This tool is meant to be used with custom templates for scientific
writing.

## Usage:
    ~~~
    panruby.rb latex|beamer|html [sourcefile] [template] [bibfile]
    panruby.rb latex|beamer|html [name] [template]
    ~~~

## Version:
 1.2

## Requirements

* Ruby version 1.9.1
* Document encoding UTF-8
* ERB

## Application Interface

You can use the following ruby commands within your ERB markdown file:

* **addextension(exts)** adds [pandoc extension](http://johnmacfarlane.net/pandoc/README.html#pandocs-markdown) to pandoc
* **putkey(key,value)** to set [template variables](http://johnmacfarlane.net/pandoc/README.html#general-writer-options) for pandoc
* **variant?** can be used to create output w.r.t. to the variant passed to panruby.rb in the commandline

## Known Issues

* Insecure call to exec
* Addhoc coding style, which needs refactoring
* Missing tests
* Missing contributors
