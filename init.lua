local modpath = minetest.get_modpath(minetest.get_current_modname())
local worldpath = minetest.get_worldpath()
package.path = package.path .. ";" .. modpath .. "/?.lua"
local db = require("db")
local entities = require("entities")
local constants = require("constants")
local settings = require("settings")

-- stores currently connected players
local mmoplayers = {}

db.init(modpath, worldpath)

minetest.register_on_dignode(function(pos, oldnode, digger)
    local name = digger:get_player_name()
    local mmoplayer = mmoplayers[name]
    mmoplayer:node_dug(oldnode.name)

    if settings.debug_mode then
        minetest.chat_send_player(
            name,
            "Node " .. oldnode.name .. " at " .. minetest.pos_to_string(pos)
        )
    end
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    mmoplayers[name] = entities.MMOPlayer(name, db)
end)

minetest.register_on_leaveplayer(function(player)
    error('POOP DICK')
    local name = player:get_player_name()
    local mmoplayer = mmoplayers[name]
    mmoplayer:save_skills()
    mmoplayers[name] = nil
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
            return false, "Invalid command: " .. param
        end
        if command == "help" then
            local help_text = commands[subcommand] or commands["help"]
            return true, help_text
        elseif command == "skills" then
            local mmoplayer = mmoplayers[name]
            local skills = mmoplayer.skills
            local skill_text = "Skills\nName: Level (Experience)"
            skill_text = skill_text .. "\n" .. string.rep("=", skill_text:len() - 6) .. "\n"
            local template = "%s%s: %s (%s)\n"
            for k, v in ipairs(constants.SKILLS) do
                skill_text = template:format(skill_text, v, skills[k].level, skills[k].experience)
            end
            mmoplayer:update_hud(skill_text, settings.hud_fade_time)
        end

        return true
    end
})

minetest.register_on_shutdown(function()
    db.close()
end)

minetest.log("action", "[mtmmo] -- Loaded!")
