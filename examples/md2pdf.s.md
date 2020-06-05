# Generates pdf versions of Obsidian Notes

Using maxdepth seem to be a good way to control this thing !!
~~~ bash
find . -name "*.md" -maxdepth 1 -print0| xargs -I{} -0 pandoc -V papersize:a4 {} -o {}.pdf
~~~

## Setup & Usage Notes

### Supporting tools
Requires a full installation of pandoc ( https://pandoc.org/ ) and a laTeX distribution (e.g. http://www.tug.org/texlive/)

### Displaying pdf's in obsidian
For now you cannot display pdf directlyin Obsdian (but I understand it's coming soon). Fear not, though

- use open with the native app (*enable the plugin!*) and all is fine