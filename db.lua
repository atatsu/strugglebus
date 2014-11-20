local sqlite = require("lsqlite3")
local constants = require("constants")

local modpath
local worldpath
local db
--local memdb

local M = {}

function M.init(_modpath, _worldpath)
    modpath = _modpath
    worldpath = _worldpath
    db = sqlite.open(worldpath .. "/mtmmo.sqlite3")
    --memdb = sqlite.open_memory()

    -- create tables we'll be using
    minetest.log("action", "[mtmmo] -- Creating tables")
    local file = io.open(modpath .. "/tables.sql", "r")
    local sql = file:read("*all"):gsub("\n", "")
    minetest.log("verbose", "[mtmmo] -- " .. sql)
    file:close()
    db:exec(sql)
end

function M.add_player(name)
    local id
    local query = string.format("SELECT id FROM players WHERE name='%s'", name)
    minetest.log("verbose", "[mtmmo] -- " .. query)
    for x in db:nrows(query) do
        -- player has already been added to the `players` table
        return x.id
    end

    if not id then
        -- player does not yet exist in the `players` table, so add them
        local query = string.format("INSERT INTO players (name) VALUES ('%s')", name)
        minetest.log("verbose", "[mtmmo] -- " .. query)
        db:exec(query)
        return nil
    end
end

function M.initialize_skills(name)
    local sql
    for k, v in pairs(constants.SKILLS) do
        -- TODO: see if this can be combined into one INSERT
        sql = (sql or "") .. string.format([[
            INSERT INTO skills (player_id, skill_id, level, experience)
            SELECT p.id, %s, 1, 0
            FROM players p
            WHERE p.name='%s';
        ]], k, name):gsub("\n", "")
    end
    minetest.log("verbose", "[mtmmo] -- " .. sql)
    db:exec(sql)
end

function M.load_skills(name)
    local skills = {}
    local query = string.format([[
        SELECT skill_id, level, experience FROM skills s, players p
        WHERE p.id=s.player_id
        AND p.name='%s'
    ]], name):gsub("\n", "")
    minetest.log("verbose", "[mtmmo] -- " .. query)
    for x in db:nrows(query) do
        skills[x.skill_id] = {
            level = x.level,
            experience = x.experience
        }
    end
    return skills
end

function M.save_skill(name, skill_id, level, experience)
    -- Saves a single skill (experience and level) for the player.
    local query = string.format([[
        UPDATE skills SET experience=%s, level=%s 
        WHERE player_id IN (
            SELECT id FROM players
            WHERE name='%s'
        )
        AND skill_id=%s;
    ]], experience, level, name, skill_id):gsub("\n", "")
    minetest.log("verbose", "[mtmmo] -- " .. query)
    db:exec(query)
end

function M.close()
    minetest.log("action", "[mtmmo] -- Closing database")
    db:close()
    --memdb:close()
end

return M
