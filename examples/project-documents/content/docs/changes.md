# Realative Paths

## Description

### Issues

#### Issue 1

The current Panruby script only allows the use of absolute paths for the `load` command and images. This leads to the problem that the *workspaces* (directories containing Markdown, image, and ERB files, as well as Panruby) that the script works with are not robust against being moved. In other words, as soon as the *workspace* is run in a different environment (a different directory), the `load` commands and images no longer work.
This makes it difficult to archive workspaces and to collaborate across multiple computers or with multiple people.

#### Problem 2

The current Panruby script carries the risk of infinite loops. Suppose the main file `main.md.erb` contains a `load` for `A.md.erb`, and that file in turn contains a `load` for `main.md.erb`. This could result in an infinite loop when loading the content.

## Goal

### Goal 1

The goal is for a workspace to function as a root directory in different environments (i.e., directories) without errors. The only conditions that must be met are:

- All necessary programs (Ruby, Pandoc, LaTeX, etc.) must also be available in the new environment.
- The structure within a workspace is preserved: Only the workspace as a whole is moved to other environments. The relative positions of all files and directories are preserved.

## Goal 2

We want to prevent `load` commands from entering infinite loops. At the same time, we want to allow files to be loaded multiple times without causing loops.

## Solution

We want to keep the file path specifications in `load` commands and when loading images relative. There are three specific components to this.

- The paths for `load` commands and image imports should be relative to the calling file.
- The paths should be usable not only when rendering to Markdown, but also when rendering to PDF using LaTeX.
- The script should automatically convert these paths to absolute paths for content generation. This means that the path to the execution environment (where the Panruby script and the Makefile are located) should not be specified explicitly but should be detected automatically.

To achieve this, I have modified the script so that the location (absolute path) of the executed Panruby script is automatically detected during execution, thereby converting the relative paths to the individual files.

To achieve this, I have introduced the following variables:

- `@current_file_in_load_exec`: Holds the path reference to the `*.md.erb` file currently being processed in which a `load` command is called
- `@load_file_paths`: Collects the paths of all `*.md` and `*.md.erb` files used during execution
- `@active_loads`: Holds the paths of all `*.md` and `*.md.erb` files that are currently being loaded, to check new `load` statements for loops.

The following commands were added to the `load` command

```ruby
 base = File.dirname(@current_file_in_load_exec)

 full = File.expand_path(file, base)
```

to concatenate the paths. The relative import path is converted to a normalized absolute path based on the current file directory. Path components such as `.` and `..` are resolved to prevent continuous chaining of relative paths.

The system then checks whether the currently processed `load` causes a loop and, if so, aborts it.

```ruby
 raise “Circular load detected: #{full}” if @active_loads.include?(full)
```

If this is not the case, the function continues, and the current `load` path is added to the necessary path collections.

```ruby
  collect_load_path(full)
  @active_loads << full
```

Next, the variable for the `load` currently being processed is cached and updated.

```ruby
  old = @current_file_in_load_exec
  @current_file_in_load_exec = full
```

The variable for the `load` currently being processed is then temporarily stored and converted.

```ruby
  old = @current_file_in_load_exec
  @current_file_in_load_exec = full
```

Next, the `load` is read and processed as usual. Afterward, the variable for the currently processed file is reset, and the pathname for the file just processed is removed from the set of current `load`s.

```ruby
ensure
    @current_file_in_load_exec = old
    @active_loads.delete(full)
end
```

There are also adjustments in the execution steps. The resolution of the arguments remains the same, which means usage via the CLI remains identical.

Before parsing, the main file must be manually added to the sets, since it is not loaded via `load`.

```ruby
collect_load_path(file)
@active_loads << File.expand_path(file)
```

The same applies to setting `current_file_in_load_exec`. After parsing, the collected paths are processed. This means file paths are abstracted into directory paths, and duplicates are removed.

```ruby
resource_dirs = @load_file_paths.map { |f| File.dirname(f) }.uniq
```

The resulting resource paths are added to a variable named `graphicspaths` in the command. This is needed for processing the relative graphics paths in LaTeX.

```ruby
latex_paths = resource_dirs.map { |p| “  {#{p}/}” }.join(“\n”)

variables << “ -V graphicspaths=\”#{latex_paths}\“”

commandstring << (variables.join)
```

Furthermore, the resource paths are appended to the Pandoc variable `--resource-path` via the command string.

To use `graphicspaths`, the LaTeX template must be extended as follows.

```latex
\usepackage{graphicx}
\graphicspath{$graphicspaths$}
```

## Build Process

>
![Build Process](./images/testimage.pdf){ width=80% }
