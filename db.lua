local sqlite = require("lsqlite3")
local constants = require("constants")
local log = require("logger")

local db

local M = {}

--- Initializes the sqlite3 database.
-- Creates a sqlite3 connection that is used for all 
-- subsequent functions. Also reads the table definitions
-- from `tables.sql` and executes them. 
-- @param modpath Path to this mod's directory (so that it can locate
--                `tables.sql`.
-- @param worldpath Path to the world directory, which is where the
--                  database file is created.
-- @param conn An existing sqlite3 connection. If this parameter is supplied
--             then this function forgoes creating the connection. This
--             is useful for testing (so that a memory database can be
--             passed in).
function M.init(modpath, worldpath, conn)
    if conn ~= nil then
        db = conn
    else
        db = sqlite.open(worldpath .. "/mtmmo.sqlite3")
    end

    -- create tables we'll be using
    log.action("Creating tables")
    local file = io.open(modpath .. "/tables.sql", "r")
    local sql = file:read("*all"):gsub("\n", "")
    log.verbose(sql)
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

function M.save_skills(name, skills)
    local sql = ""
    local query_template = [[
        UPDATE skills SET experience=%s, level=%s
        WHERE player_id IN (
            SELECT id FROM players
            WHERE name='%s'
        )
        AND skill_id=%s;
    ]]
    for skill_id, _ in pairs(constants.SKILLS) do
        local skill = skills[skill_id]
        local experience = skill.experience
        local level = skill.level
        sql = sql .. string.format(
            query_template,
            skill.experience,
            skill.level,
            name,
            skill_id
        ):gsub("\n", "")
    end
    log.verbose(sql)
    db:exec(sql)
end

function M.close()
    log.action("Closing database")
    db:close()
end

return M
