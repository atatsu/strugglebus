
local modpath = minetest.get_modpath(minetest.get_current_modname())
local worldpath = minetest.get_worldpath()
package.path = package.path .. ";" .. modpath .. "/?.lua"
package.cpath = package.cpath .. ";" .. modpath .. "/lib/?.so"
local db = require("db")
local Player = require("player")

local players = {}

db.init(modpath, worldpath)

minetest.register_on_dignode(function(pos, oldnode, digger)
    --minetest.log("Node " .. oldnode.name .. " at " .. minetest.pos_to_string(pos) .. 
    --    " dug by " .. digger:get_player_name())
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    -- db.add_player(name)
    players[name] = Player(name, db)
end)

local commands = {
    ["help"] = [[Available commands:
    skills (/mtmmo skills)
    rank   (/mtmmo rank)
Use /mtmmo help <command> for specifics on a command's function.]], 
    ["skills"] = "Display a list of all your skills, their level, and current experience.", 
    ["rank"] = "Display a list of the rank (total of all skill levels) of all player's on the server."
}

minetest.register_chatcommand("mtmmo", {
    params = "<command>",
    description = "Use 'help' (/mtmmo help) for a list of available mtMMO commands.", 
    func = function(name, param)
        local found, _, command, subcommand = param:find("^([^%s]+)%s*([^%s]*)$")
        if found == nil then
            --minetest.chat_send_player(name, "Invalid command: " .. param)
            return false, "Invalid command: " .. param
        end
        if command == "help" then
            local help_text = commands[subcommand] or commands["help"]
            minetest.chat_send_player(name, help_text)
        end

        return true
    end
})

minetest.register_on_shutdown(function()
    db.close()
end)

minetest.log("action", "[mtmmo] -- Loaded!")
