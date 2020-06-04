# README for pre_Script

This is a *proof of concept* release an an Obsidian Support tool calles pre_Script.  
Here, proof of concept means that I publish it to gather feedback on whether people find the idea useful at all, how the approach I have taken could be improved and so on.

It also means that the coding of this is more of the "quick hack" sort than the "professional product" sort. If this turns out to be something the community appreciates then I will do my best to make a proper project of it. Hopefully others may wish to help. 

## What is pre_Script?

pre_Script supports users of [Obsidian](https://obsidian.md/) with script-based maintenance of their Vault.

It provides mechanisms for:
+ storing Scripts in the Vault in an organized way
+ defining the scope of a Script execution (i.e. the whole Vault or only a specific part of the Vault)
+ running the scripts (or possibly a selected subset only)

As the name implies the design intention of pre-Script is that it be run *prior* to starting Obsidian (presumably in some kind of shell startup script). There are also reasons to run it *after* closing an Obsidian session (to do backups, for example) but that name was already taken!

In principle, you could also run it from a terminal session in parallel to Obsidian, but personally, I feel it might be better to avpid doing that, just in case.

## How does it work?

As you probably know, your Obsidian Vault is nothing other than a tree of directories and files.

To store Scripts in you Vault you should:

1. create a sub-directory called "scripts" where you will store the Scripts

2. place each Script in a file in that directory, naming them with the extension ".s.md"
   + In other words, Scripts are just Markdown files, and both the "scripts" directory, and the Script files will be visible in Obsidian

3. The Script file itself may contain arbitrary markdown (I assume this will be used to document the script). 
   Within this markdown you will place a 'code fenced' section of text containg the executable statements for the script. 
   The code fence to be used is the common "~~~", the less comonn variant using back-ticks will not be recognised.
   The leading fence should be followed by a blank character and a tool specification which is needed to run this script segment.
   (See the [examples][https://github.com/spacejunky/pre_script/examples] directory on github to make this clearer) 

4. In recognition of the multi-platform nature of Obsidian (currently Windws, Mac and linux) pre-Script allows any Script file to contain several equivalent implementations of the script functions and will select whichever is appropriate, based on matching which 'tools' it is told are available (via the -t x,y,z option) against the tool that each code-fenced section says it would need. First match wins.

And there you have it. You have created your first pre_Script script.

To help tighten the scope of action of the Scripts pre_Script will set the current working directory for the script execution to the directory which contained the "scripts" directory. By convention, scripts should follow the principle of only working on Notes conatined in that current directory, or in sub-directories of it. pre-Script makes no attempt to enforce that (after all it's your Vault, and you can do what you want with it), but it seems like a convention that is helpful and useful.

Based on this convention pre_Script makes sure it excutes the scripts whhich are deepest in the Vault tree first, so their results may safely be refernced later, from scriots higher up the tree.

To give a conccrete example, assume you have a special directory where you keep your Day Notes (say, "myVault/Daily") and that you wish to write a script to prodcue some sort of summary of those Day Notes.

+ you create a "scripts" directory :: "myVault/Daily/scripts"
+ you create your script file in that directory :: "myVault/Daily/scripts/SummariseDayNotes.s.md"
+ you add one or more executable code fenced segments to the script file, along with maybe some documentation

When pre-Script is told to execute SummariseDayNotes it will set the working directory to "myVault/Daily" so that any new Notes naively created by the script will appear next to the Day Notes they are summarising. 

## Script input & output

The Script text is fed to which ever tool gets matched via the standard input.

Unless the script redirects them, stdout & stderr are thrown away. If you really need to see them (perhaps to debug a script) give the "-V" option (be very verbose) on the command line.

## Commandline flags & parameters

pre_script will give help information with the "help" command.

## Ideas for things to script

There are many useful functions which could be supported by scripting, for example:

+ creation of new Notes, for example
  + Composite Day Notes
  + Merge and Split Notes
  + Create new Notes with imported contents
  + Generating Notes with Vault statistics (e.g. files changed since yesterday, word counts)

+ modifying Notes
  + building Table of Content sections to Notes (e.g. based on Note headers)
  + converting embedded Note links to inline text (an "include" processor)

+ Vault housekeeping and statistics
  + triggering git actions on the Vault (e.g. daily commit, daily push, ...)
  + Creating backup copies of the Vault
  + exporting the Vault to some Cloud location

+ format conversions
  + generate pdf, docx, gfm (or one of many other formats) from Notes
    + probably using [pandoc](https://pandoc.org/)

Most of these ideas have already been sighted in the Obsidian Forum.

Our imaginations are the limit!

It is my hope that, by providing a semi-structured environment, pre-Script can help the community create a "library" of useful scripts,
and also encourage people to extend existing scripts with alternate implementations to cover the platforms supported by Obsidian.
