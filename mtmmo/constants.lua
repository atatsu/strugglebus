local M = {}

M.DIGGING = 1
M.MINING = 2
M.LUMBERJACKING = 3
M.CULTIVATING = 4

M.SKILLS = {
    [M.CULTIVATING] = "Cultivating",
    [M.DIGGING] = "Digging",
    [M.LUMBERJACKING] = "Lumberjacking",
    [M.MINING] = "Mining",
}

M.HELP = {
    help = "Available subcommands: online, ranks, skills\nUse /mtmmo help <subcommand> for specifics on a subcommand's function.",
    skills = "Display a list of all your skills, their level, and current experience. (/mtmmo skills)",
    ranks = "Display a list of the rank (total of all skill levels) of all player's on the server (online and offline). (/mtmmo ranks)",
    online = "Display a list of players currently online. (/mtmmo online)"
}

M.SOUND_LEVEL_UP = "mtmmo_levelup"

return M
