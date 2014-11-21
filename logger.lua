local M = {}

M.verbose = function(msg)
    if minetest ~= nil then
        minetest.log("verbose", "[mtmmo] -- " .. msg)
    end
end

M.action = function(msg)
    if minetest ~= nil then
        minetest.log("action", "[mtmmo] -- " .. msg)
    end
end

return M
