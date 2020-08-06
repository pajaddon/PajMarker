# PajMarker

This addon aims to provide raid leaders (or anyone who is responsible for making creatures in raids) a more automated method of doing so.

In short, lists are configured using the graphical interface, then when you click on monsters and hover over monsters with your mouse, the addon marks them up for you.

## BREAKING CHANGE IN 2.0

We no longer load lists from the config.lua file, rather everything is stored in settings (so in your WTF folder). To recover your old lists, follow these steps:

1. Close down World of Warcraft
2. Open the PajMarker addon folder
3. Edit the `PajMarker.toc` file and add a line saying `config.lua` (This will tell the addon to load your old configuration file)
4. Launch World of Warcraft and log into a character with the addon enabled
5. Type `/pm loadoldlists` - this will load the lists configured in the `config.lua` file and override your current profile.

## How to use the GUI

I'm not a GUI expert, so these instructions might be required to read.

Each list is visible as its own tab in the Lists interface (`/pm lists`)

When looking at a list, you will see a list of all added monsters.  
On the left side under the monster, you will see the marks that are enabled for this monster. The leftmost mark is the one that will be applied to the first mob of this name (if the marksi still available), the second mark from the left will be the second and so on.
On the right side under the monster, you will see marks that are not currently in use for this monster.  
To remove a mark that is enabled for a monster, click it until it's the leftmost position, then click it one more time.  
To increase the priority of a mark that is enabled for a monster, click it once. (This will move it one step to the left).  
To enable a mark that is not in use for a monster right now, click the mark in the "Disabled" group.

- To create a new list, press the "New..." tab, type in the name of your list in the "Create new list" textbox and press Enter.
- To add a new monster to a list, select the list in the tabs, scroll all the way down and type the name of the monster in the "Add new monster" textbox and press Enter.

## Chat commands:

```
/pm clear - Clear all raid markers currently assigned to units
/pm export - Export lists to a string
/pm import - Import lists from a string
/pm lists - Configure lists
/pm config - Open the addon config dialog
/pm usage - Shows this help text
/pm saveoldlists - Save old list into new saving method
/pm reset - Reset the current session
```

## Video of addon in action:

https://youtu.be/p_E8L8gIsDw
