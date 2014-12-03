Minetest MMO
============
Version: 0.1.0alpha

## What does this mod do?
This mod was inspired by mcMMO but doesn't really aim to reproduce it. It'll
have similarities I'm sure, but for the most part it's just my own spin
on the idea.

The primary thing (at least at this point) that the mod does is awards experience
for nodes dug, depending on the type of node. Nodes that award experience all fall
into a category specific to their type (Mining and Digging are a few example categories).
Each category has a level, that can increase once enough experience has been accumulated.
As you gain levels you'll unlock benefits specific to the category, which is not yet
implemented, or even decided as to what these "benefits" are.

For a complete listing of the experience gained from digging particular nodes see the 
[Node Values page](https://github.com/atatsu/strugglebus/wiki/Node-Values) on the wiki.
At this point the experience values are very fluid. And I certainly welcome input.

### Short term goals
TODO

### Long term goals
TODO

## Requirements
This mod will not work unless the below requirements are satisfied. Please refer to their
respective documentations if you need help getting them setup/configured. If you're using
a Linux distribution with a package manager it should be fairly trivial.

* Minetest 0.4.x (I've only used 0.4.10)
* [SQLite3](http://www.sqlite.org/) (I'm using 3.8.7.2)
* [LuaSQLite3](http://lua.sqlite.org/index.cgi/home)
 * [LuaRocks](http://luarocks.org/) makes this easy to get 

## Configuration
* `hud_fade_time` - Controls the number of seconds that informative HUDs are displayed on 
                  screen (for instance when running `/mtmmo skills`). Default: `10`
* `database_name` - Name to give the database file that is created in the world's
                  directory. Default: `mtmmo.sqlite3`

## Commands (in game)
Rather than register a bunch of different commands and clutter up the game's `/help` listing
I instead registered one command (`/mtmmo`) that has subcommands, if you will, that can be passed.
Read on for a listing of all available (sub)commands.

 * `/mtmmo` - Displays the mtMMO help text.
 * `/mtmmo help` - Displays a list of all subcommands and a brief description of each.
 * `/mtmmo help <subcommand>` - Displays the help text for a specific subcommand.
 * `/mtmmo skills` - Displays a HUD briefly that shows a listing of all your skills, 
                     their level, and current experience.
 * `/mtmmo ranks` - Displays a HUD briefly that shows a list of all players that have been
                   on the server and a total of all their skills combined.
 * `/mtmmo online` - Displays a list of the current players online.

## Mod compatibility
If a mod is listed here it means `mtMMO` is friendly with the given mod's 
nodes (for experience gained when digging a node and such).

* default

## Media licenses

*mtmmo_levelup.ogg* is taken from [Wind-Chimes01.wav](http://www.freesound.org/people/Bassmonkey91/sounds/134070/) 
by **Bassmonkey91** ([CC BY 3.0](http://creativecommons.org/licenses/by/3.0/))
