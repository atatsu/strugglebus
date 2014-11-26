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
    help = "Available subcommands: skills, rank\nUse /mtmmo help <subcommand> for specifics on a subcommand's function.",
    skills = "Display a list of all your skills, their level, and current experience. (/mtmmo skills)",
    rank = "Display a list of the rank (total of all skill levels) of all player's on the server (online and offline). (/mtmmo rank)"
}

return M
