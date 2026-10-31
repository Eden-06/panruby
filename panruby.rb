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

require 'set'

@variant=:latex
@keys=Hash.new
@extensions=%w[ markdown yaml_metadata_block grid_tables table_captions smart fenced_divs ]

# path of file on which load was called
@current_file_in_load_exec=nil

# Set of paths of all load-function calls and main file
@load_file_paths = Set.new #

# Set as a Stack of all actual files in processing state
@active_loads = Set.new    

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

  # holds actual directory of 'current_file_in_load_exec' (currently PROCESSED.erb)
  base = File.dirname(@current_file_in_load_exec)

  # converts relative path to absolute path of the CALLED file in load-command
  full = File.expand_path(file, base) 

  # condition to avoid loop-imports (avoid endless loops)
  raise "Circular load detected: #{full}" if @active_loads.include?(full)

  # Add path to set of paths of all used .erb files
  collect_load_path(full)

  # Add path to set (stack) of files currently being PROCESSED
  @active_loads << full

  # saves current_file_in_load_exec for reset at the end of this function
  old = @current_file_in_load_exec

  # set ccurrent_file_in_load_exec to CALLED file in load-command parameters
  @current_file_in_load_exec = full 

  content = ''
  begin
    open(full) do |f|
      if /.*[.]md[.]erb$/ =~ full  # check if the called file is .erb
        # Read and concatenate .erb and .md files
        engine=ERB.new(f.readlines.join, trim_mode: "<>")
        # process ruby code
        content=engine.result(binding)
      else
        content=f.read
      end
    end
  ensure
    # Guarantees that current_file_in_load_exec and active_loads will be reset in case of errors
    @current_file_in_load_exec = old
    @active_loads.delete(full)
  end
  content #returns content
end

# Function to separate colletion of the paths in separate function
def collect_load_path(path)
  # Add path to set of file paths of read load-command
  @load_file_paths << path
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

# Add main *.md.erb file to sets 
collect_load_path(file)
@active_loads << File.expand_path(file)

#parse file as erb template
input=file
if /.*[.]md[.]erb$/ =~ file
  puts "# process erb #"
  input=name+".tmp"
  # holds path for actual processed .erb
  @current_file_in_load_exec = File.expand_path(file)
  open(file) do|f|
    engine=ERB.new(f.readlines.join, trim_mode: "<>")
    File.open(input,"w+") do|t|
      t.write(engine.result(binding))
    end
  end
end

@active_loads.delete(@current_file_in_load_exec)
resource_dirs = @load_file_paths.map { |f| File.dirname(f) }.uniq

commandstring=String.new(@commandstring)
commandstring=commandstring % [input,@extensions.join("+"),template,output]
commandstring << " --bibliography=\"%s\" --biblatex"%bibfile if File.exist?(bibfile)

variables=[]
@keys.each_pair do|k,v|
 variables << " -V %s=\"%s\"" % [k,v]
end

# --- separate var for LaTeX graphicspath  ---
latex_paths = resource_dirs.map { |p| "  {#{p}/}" }.join("\n")

variables << " -V graphicspaths=\"#{latex_paths}\""

commandstring << (variables.join)

# --- var for Pandoc resource paths  ---
sep = File::PATH_SEPARATOR
pandoc_resource_path = resource_dirs.join(sep)
commandstring << " --resource-path=\"#{pandoc_resource_path}\""
commandstring << " --listings --no-highlight"

puts "# generated commandstring #"
puts commandstring

exec(commandstring) # inherently insecure
