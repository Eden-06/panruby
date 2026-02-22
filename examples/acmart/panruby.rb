# PanRuby is a build tool for the transformation of multimarkdown to
# various formats based on pandoc.
# The source file could be either a standard *.md file and *.md.erb
# containing ERB templates.
#
# Usage:
#  panruby.rb latex|beamer|html [sourcefile] [template] [bibfile]
#  panruby.rb latex|beamer|html [name] [template]
#
# Author: Thomas Kühn
# Version: 1.2.3


#!/usr/bin/ruby
# encoding: UTF-8
require 'erb'

@variant=:latex
@keys=Hash.new
@extensions=%w[ markdown yaml_metadata_block grid_tables table_captions smart fenced_divs ]

# Returns the set of used pandoc extensions
def extensions
 @extensions
end

# Adds the list of pandoc extensions
def addextension(ext)
 e=ext.to_a
 @extensions.push(*e).uniq! unless e.empty?
end

# Adds keys from several lines of text.
# Each key value pair must be placed on a separate line delimited by a colon (:).
# [Depreceted]
def addkeys(str)
 return false if str.nil?
 s=str.to_s
 s.each_line do|l|
  if l =~ /((\w|[-])+)\s*[:]\s*(.*)$/
    @keys[$1]=$3
  end
 end
 true
end

#Use getkey instead
# [Depreceted]
def key(value)
 @keys[value]
end

#Use putkey instead
# [Depreceted]
def key=(value) 
 @keys[value]=value
end

#Returns the value assoziated to a given key or nil, if the key was not yet assigned.
def getkey(value)
 @keys[value]
end

#Assign the given value to the given key.
def putkey(key,value)
 @keys[key]=value
end

# Returns the variant of the build, i.e., beamer.
def variant?
 @variant
end

# Loads another markdown file into this file.
# If the file is an ERB file it will be proccessed by the ERB template engine.
def load(file)
	r=''
  open(file) do|f|
    if /.*[.]md[.]erb$/ =~ file
	    engine=ERB.new(f.readlines.join, trim_mode: "<>")
	    r=engine.result(binding)
    else
      r=f.read
    end
	end
  r
end


# Start of execution

if ARGV.size<3
  #Better options:
  # panruby latex|beamer|html -s -t template -b [bibfile] [name or sourcefile]

  puts " panruby.rb latex|beamer|html [sourcefile] [template] [bibfile]" 
	puts " panruby.rb latex|beamer|html [name] [template]" 
	exit
end

case ARGV[0].strip
 when /beamer/i then 
   @commandstring="pandoc -s \"%s\" -f %s -t beamer --slide-level 2 --template=\"%s\" -o \"%s\""
   @ext=".tex"
   @variant=:beamer
 when /html/i   then 
   @commandstring="pandoc -s \"%s\" -f %s -t html  --template=\"%s\" -o \"%s\" --mathjax"
   @ext=".html"
   @variant=:html
 when /latex/i  then 
   @commandstring="pandoc -s \"%s\" -f %s -t latex --template=\"%s\" -o \"%s\""
   @ext=".tex"
   @variant=:latex
 else     
	puts " panruby.rb latex|beamer|html [sourcefile] [template] [bibfile]" 
	puts " panruby.rb latex|beamer|html [name] [template]" 
	exit
end

name=ARGV[1].sub(/[.]\w+$/,"")

file=if ARGV.size==3 then
       if File.exist?(name+".md.erb")
         name+".md.erb"
       else
         name+".md"
       end
     else
       ARGV[1]
     end

unless File.exist?(file)
  puts " file %s not found"%file
	exit
end

template=ARGV[2]
unless File.exist?(template)
  puts " template %s not found" %template
	exit
end
bibfile=if ARGV.size<4 then name+".bib" else ARGV[3] end

output=name+@ext
if File.exist?(output)
  puts " outputfile %s already exist" %output
	# exit
end

#parse file as erb template
input=file
if /.*[.]md[.]erb$/ =~ file
  puts "# process erb #"
  input=name+".tmp"
  open(file) do|f|
    engine=ERB.new(f.readlines.join, trim_mode: "<>")
    File.open(input,"w+") do|t|
      t.write(engine.result(binding))
    end
  end
end
commandstring=String.new(@commandstring)
commandstring=commandstring % [input,@extensions.join("+"),template,output]
commandstring << " --bibliography=\"%s\" --biblatex"%bibfile if File.exist?(bibfile)
variables=[]
@keys.each_pair do|k,v|
 variables << " -V %s=\"%s\"" % [k,v]
end

commandstring << (variables.join)
puts "# generated commandstring #"
puts commandstring

exec(commandstring) # inherently insecure
