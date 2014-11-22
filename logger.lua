local M = {}

M.verbose = function(msg)
    if minetest ~= nil then
        minetest.log("verbose", "[mtmmo] -- " .. msg)
    else
        --print(msg)
    end
end

M.action = function(msg)
    if minetest ~= nil then
        minetest.log("action", "[mtmmo] -- " .. msg)
    else
        --print(msg)
    end
end

return M
