
local modpath = minetest.get_modpath(minetest.get_current_modname())
local worldpath = minetest.get_worldpath()
package.path = package.path .. ";" .. modpath .. "/?.lua"
package.cpath = package.cpath .. ";" .. modpath .. "/lib/?.so"

local db = require("db")
db.init(modpath, worldpath)

minetest.register_on_dignode(function(pos, oldnode, digger)
    --minetest.log("Node " .. oldnode.name .. " at " .. minetest.pos_to_string(pos) .. 
    --    " dug by " .. digger:get_player_name())
end)

minetest.register_on_joinplayer(function(player)
    db.add_player(player:get_player_name())
end)

minetest.register_on_shutdown(function()
    db.close()
end)

minetest.log("action", "[mtmmo] -- Loaded!")
