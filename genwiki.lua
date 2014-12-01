package.path = package.path .. ";" .. "./mtmmo/?.lua"

local nodevalues = require("nodevalues")
local constants = require("constants")

local nodes = {}

for k, v in pairs(nodevalues) do
    local mod_node = k
    local category, exp = unpack(v)
    category = constants.SKILLS[category]
    local found, _, modname, nodename = mod_node:find("^([^%s]+):([^%s]+)$")
    
    if nodes[category] == nil then
        nodes[category] = {}
    end

    if nodes[category][modname] == nil then
        nodes[category][modname] = {}
    end

    nodes[category][modname][nodename] = exp
end

local sort = function(t)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    table.sort(keys)
    local i = 0
    local iter = function()
        i = i + 1
        if keys[i] == nil then return nil
        else return keys[i], t[keys[i]]
        end
    end
    return iter
end

local output = ""

for category, modnodes in sort(nodes) do
    output = output .. "##" .. category .. "\n"

    for modname, nodes in sort(modnodes) do
        output = output .. "###" .. modname .. "\n"

        for nodename, exp in sort(nodes) do
            output = output .. "`" .. nodename .. "`" .. " = " .. "`" .. exp .. "`" .. "\n\n"
        end
    end
end

local file = io.open("./wiki/Node-Values.md", "w")
    file:write(output)
file:close()
