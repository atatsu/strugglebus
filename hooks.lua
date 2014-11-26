local db = require("db")
local entities = require("entities")
local constants = require("constants")
local settings = require("settings")

local M = {}
M.mmoplayers = {} -- stores currently connected players

--- Handles a joining player.
function M._register_on_joinplayer(player)
    local name = player:get_player_name()
    local mmoplayer = entities.MMOPlayer(name, db)
    M.mmoplayers[name] = mmoplayer
end

--- Handles a leaving player.
function M._register_on_leaveplayer(player)
    local name = player:get_player_name()
    local mmoplayer = M.mmoplayers[name]
    mmoplayer:save_skills()
    M.mmoplayers[name] = nil
end

--- Handles a player digging up a node.
function M._register_on_dignode(pos, oldnode, digger)
    local name = digger:get_player_name()
    local mmoplayer = M.mmoplayers[name]
    mmoplayer:node_dug(oldnode.name)

    if settings.debug_mode then
        minetest.chat_send_player(
            name, 
            "Node " .. oldnode.name .. " at " .. minetest.pos_to_string(pos)
        )
    end
end

--- Handles the server shutting down.
function M._register_on_shutdown()
    for _, v in pairs(M.mmoplayers) do
        v:save_skills()
    end
    db.close()
end

--- Handles chat commands.
function M._process_chatcommand(name, param)
    local found, _, command, subcommand = param:find("^([^%s]+)%s*([^%s]*)$")
    if found == nil then
        return false, "Invalid command: " .. param
    elseif command == "help" then
        local text = constants.HELP[subcommand] or constants.HELP.help
        return true, text
    elseif command == "skills" then
        -- format a list of all the player's skills and update the HUD
        -- with them
        mmoplayer = M.mmoplayers[name]
        local skills = mmoplayer.skills
        skill_text = "Skills\nName: Level (Experience)\n"
        skill_text = string.format("%s%s\n", skill_text, string.rep("=", skill_text:len() - 8))
        for i, v in ipairs(constants.SKILLS) do
            skill_text = string.format("%s%s: %s (%s)\n", skill_text, v, skills[i].level, skills[i].experience)
        end
        mmoplayer:update_hud(skill_text, settings.hud_fade_time)
    else
        return false, "Invalid subcommand: " .. param
    end

    return true
end

--- Initialize all hooks.
-- All `register_on` calls occur in this function so that
-- the global `minetest` object can be stubbed out for
-- testing purposes. The `db` module is also initialized
-- here.
-- @param modpath Directory path to this mod's location.
-- @param worldpath Directory path to the world directory
--                  (database file is created there).
function M.init(modpath, worldpath)
    db.init(modpath, worldpath)
    minetest.register_on_joinplayer(M._register_on_joinplayer)
    minetest.register_on_leaveplayer(M._register_on_leaveplayer)
    minetest.register_on_dignode(M._register_on_dignode)
    minetest.register_on_shutdown(M._register_on_shutdown)
    minetest.register_chatcommand("mtmmo", {params = "<command>", func=M._process_chatcommand})
end

return M
