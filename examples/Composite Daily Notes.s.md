# Composite Daily Notes

This is a simple script to locate the most recent 3 days of Daily Notes and generate a composite file containg embed links to them.

The earliest request I saw for this was from *@scmwiz* and is now in the Obsidian [Forum](https://forum.obsidian.mdt/composite-day-notes/67).

Note that it doesn't cover his request for Daily Notes from the future as this version works from file times (which are unlikely to be in the future) rather than from naming conventions. 

I chose this approach to avoid having to work with the many possible Note titles people might choose to give their Daily Notes (although I *do* assume that the first two digits are "20")

~~~ nix
find . -name "20*.md" -ctime -3 -exec echo \![[{}]] ';'|sort >composite.daynote.md
echo "composite.daynote last run at " `date -Iseconds` >>composite.daynote.md
~~~

## Notes

Playing with this was what caused me to ask for css to get "naked" embeds, which *@death_au* kinly provided. It is now in the [Forum](https://forum.obsidian.md/t/naked-embeds-css-tweak/72) too.