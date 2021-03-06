local db = require("db")
local entities = require("entities")
local constants = require("constants")
local settings = require("settings")

--- Sorts a dictionary table.
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
    if minetest.check_player_privs(name, {creative = true}) or minetest.setting_getbool("creative_mode") then
        return
    end

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
    local mmoplayer = M.mmoplayers[name]
    local found, _, command, subcommand = param:find("^([^%s]+)%s*([^%s]*)$")
    if found == nil then
        return false, "Invalid command: " .. param
    elseif command == "help" then
        local text = constants.HELP[subcommand] or constants.HELP.help
        return true, text
    elseif command == "skills" then
        -- format a list of all the player's skills and update the HUD with them
        local skills = {}
        for skill_id, skill_name in pairs(constants.SKILLS) do
            skills[skill_name] = mmoplayer.skills[skill_id]
        end

        local skill_text = "Skills\nName: Level (Experience)\n"
        skill_text = string.format("%s%s\n", skill_text, string.rep("=", skill_text:len() - 8))
        for skill_name, skill_stats in sort(skills) do
            skill_text = string.format(
                "%s%s: %s (%s)\n",
                skill_text, 
                skill_name, 
                skill_stats.level,
                skill_stats.experience
            )
        end

        mmoplayer:update_hud(skill_text, settings.hud_fade_time)
    elseif command == "ranks" then
        local ranks = db.get_ranks()
        local rank_text = "Ranks\nName: Rank\n"
        local rank_text = string.format(
            "%s%s\n",
            rank_text,
            string.rep("=", rank_text:len() - 7)
        )
        for _, v in ipairs(ranks) do
            rank_text = string.format(
                "%s%s: %s\n",
                rank_text,
                v.name, 
                v.rank
            )
        end
        mmoplayer:update_hud(rank_text, settings.hud_fade_time)
    elseif command == "online" then
        local current_players = {}
        for k, _ in pairs(M.mmoplayers) do
            current_players[#current_players+1] = k
        end
        table.sort(current_players)
        local online_text = "Online Players\n"
        online_text = string.format(
            "%s%s\n", 
            online_text,
            string.rep("=", online_text:len() - 1)
        )
        for _, v in ipairs(current_players) do
            online_text = string.format("%s%s\n", online_text, v)
        end
        mmoplayer:update_hud(online_text, settings.hud_fade_time)
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
    minetest.register_chatcommand("mtmmo", {params = "<command> (Use '/mtmmo help' for more info)", func=M._process_chatcommand})
end

return M
