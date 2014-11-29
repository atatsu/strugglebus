local M = {}

M.verbose = function(msg)
    minetest.log("verbose", "[mtmmo] -- " .. msg)
end

M.action = function(msg)
    minetest.log("action", "[mtmmo] -- " .. msg)
end

return M
