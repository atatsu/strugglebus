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

return M
