Minetest MMO
============
Version: 0.1.0alpha

## What does this mod do?
This mod was inspired by mcMMO but doesn't really aim to reproduce it. It'll
have similarities I'm sure, but for the most part it's just my own spin
on the idea.

### Short term goals
TODO

### Long term goals
TODO

## Requirements
This mod will not work unless the below requirements are satisfied. Please refer to their
respective documentations if you need help getting them setup/configured. If you're using
a Linux distribution with a package manager it should be fairly trivial.
* [SQLite3](http://www.sqlite.org/)
* [LuaSQLite3](http://lua.sqlite.org/index.cgi/home)
 * [LuaRocks](http://luarocks.org/) makes this easy to get 

## Configuration
* `hud_fade_time` - Controls the number of seconds that informative HUDs are displayed on 
                  screen (for instance when running `mtmmo skills`). Default: `10`
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
 * `/mtmmo rank` - Displays a HUD briefly that shows a list of all players that have been
                   on the server and a total of all their skills combined.

## Mod compatibility
If a mod is listed here it means `mtMMO` is friendly with the given mod's 
nodes (for experience gained when digging a node and such).

* default
