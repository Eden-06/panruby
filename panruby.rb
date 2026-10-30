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

require 'set' # REVIEW ADD_CODE

@variant=:latex
@keys=Hash.new
@extensions=%w[ markdown yaml_metadata_block grid_tables table_captions smart fenced_divs ]
@current_file=nil # REVIEW ADD_CODE

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
# ===================================================
# REVIEW OLD_CODE LOAD FUNCTION
# ===================================================
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
# ===================================================
# REVIEW NEW_CODE LOAD FUNCTION
# ===================================================
# Explanation
# ===================================================
def load(file)
  base = File.dirname(@current_file) # holds actual directory of 'current_file' (actual PROCESSED .erb)
  full = File.expand_path(file, base) # converts relative path to absolute path of the CALLED file in load-command parameters

  old = @current_file # save current PROCESSED .erb file

  # set current_file to CALLED file in load-command parameters
  # JUMP in address of called file
  @current_file = full 

  content = '' # FIXME split init and assign
  begin
    open(full) do |f|
      if /.*[.]md[.]erb$/ =~ full  # check if the called file is .erb
        engine=ERB.new(f.readlines.join, trim_mode: "<>") # Read and concat .erb and .md files
        content=engine.result(binding)  # ruby code verarbeiten with result-call
      else
        content=f.read # below
        # f.read liest ganzen dateiinhalt auf einmal und gibt einen einzigen string zurück
        # f.readline.join liest datei zeilenweise in Array und verbindet arrayelemente zu string
      end
    end
  ensure  # Damit wird @current_file auch dann zurückgesetzt, wenn beim Öffnen oder Auswerten einer Datei ein Fehler auftritt.
    # JUMP BACK of currend (processed file (at the begin of the function call))
    @current_file = old
  end
  content
end
# ===================================================
# REVIEW END
# ===================================================

# ===================================================
# REVIEW ADD_CODE FUNCTION: collect_load_paths
# ===================================================
def collect_load_paths(file, visited = Set.new)
  return [] if visited.include?(file)
  visited << file

  content = open(file) { |f| f.readlines.join }
  paths = content.scan(/load\(["']([^"']+)["']\)/).flatten

  all = []

  paths.each do |p|
    full = File.expand_path(p, File.dirname(file))
    all << full
    all.concat(collect_load_paths(full, visited))
  end

  all
end
# ===================================================
# REVIEW END
# ===================================================

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

# ===================================================
# REVIEW ADD_CODE
# ===================================================
all_md_files = collect_load_paths(file)
all_md_files << File.expand_path(file)

resource_dirs = all_md_files.map { |f| File.dirname(f) }.uniq
# ===================================================
# REVIEW EMD
# ===================================================

#parse file as erb template
input=file
if /.*[.]md[.]erb$/ =~ file
  puts "# process erb #"
  input=name+".tmp"
  @current_file = File.expand_path(file) # REVIEW ADD_CODE - holds path for actual processed .erb
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

# ===================================================
# REVIEW ADD_CODE FILTERS
# ===================================================
# ad luafilter: svg-to-pdf
lua_filter = File.join(Dir.pwd, "svg-to-pdf.lua")
commandstring << " --lua-filter=\"#{lua_filter}\"" if File.exist?(lua_filter)

# ad luafilter: convert md-links to LaTeX hyperref
lua_filter_crossrefs = File.join(Dir.pwd, "latex-crossrefs.lua")
commandstring << " --lua-filter=\"#{lua_filter_crossrefs}\"" if File.exist?(lua_filter_crossrefs)
# ===================================================
# REVIEW END
# ===================================================

variables=[]
@keys.each_pair do|k,v|
 variables << " -V %s=\"%s\"" % [k,v]
end

# ===================================================
# REVIEW ADD_CODE path-handling call
# ===================================================
# --- separate var for LaTeX graphicspath  ---
latex_paths = resource_dirs.map { |p| "  {#{p}/}" }.join("\n")

variables << " -V graphicspaths=\"#{latex_paths}\""
# ===================================================
# REVIEW END
# ===================================================

commandstring << (variables.join)

# ===================================================
# REVIEW ADD_CODE
# ===================================================

sep = File::PATH_SEPARATOR
pandoc_resource_path = resource_dirs.join(sep)
commandstring << " --resource-path=\"#{pandoc_resource_path}\""
commandstring << " --listings --no-highlight"
# ===================================================
# REVIEW END
# ===================================================

puts "# generated commandstring #"
puts commandstring

exec(commandstring) # inherently insecure
