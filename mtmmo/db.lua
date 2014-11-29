local sqlite = require("lsqlite3")
local constants = require("constants")
local log = require("logger")
local settings = require("settings")

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
        db = sqlite.open(worldpath .. settings.database_name)
    end

    -- create tables we'll be using
    log.action("Creating tables")
    local file = io.open(modpath .. "/tables.sql", "r")
    local sql = file:read("*all"):gsub("\n", "")
    log.verbose(sql)
    file:close()
    db:exec(sql)
end

--- Add a player to the `players` table and return their `id`.
-- Adds a player to the `players` table if they are not already
-- present. Additionally, if an INSERT is necessary also initialize
-- all their skills in the `skills` table. Returns the player's
-- id in either case.
-- @param name Name of the player to add.
-- @return integer id
function M.add_player(name)
    local id
    local query = string.format("SELECT id FROM players WHERE name='%s';", name)
    log.verbose(query)
    db:exec(query, function(udata, cols, values, names) 
        id = tonumber(values[1]) 
        return 0 -- lsqlite3 wants callback to return 0 if successful
    end)

    if not id then
        -- player does not yet exist in the `players` table, so add them
        local query = string.format([[
            INSERT INTO players (name) VALUES ('%s');
            SELECT id FROM players WHERE name='%s';
        ]], name, name):gsub("\n", "")
        log.verbose(query)
        db:exec(query, function(udata, cols, values, names)
            id = tonumber(values[1])
            return 0 -- lsqlite3 wants callback to return 0 if successful
        end)

        -- now initialize all the player's skills
        local num_skills = #constants.SKILLS
        local sql = "INSERT INTO skills (player_id, skill_id, level, experience) VALUES"
        for k, _ in ipairs(constants.SKILLS) do
            local term = k < num_skills and "," or ";"
            sql = string.format(" %s (%s, %s, 1, 0)%s", sql, id, k, term)
        end
        log.verbose(sql)
        db:exec(sql)
    end

    return id
end

--- Retrieve an up-to-date table of a player's skills.
-- @param player_id Id of the player.
-- @return table Player's skills in the form of:
--               {skill_id1 = {level = x, experience = x},
--                skill_id2 = {level = x, experience = x}}
function M.load_skills(player_id)
    local skills = {}
    local query = string.format([[
        SELECT skill_id, level, experience FROM skills s
        WHERE s.player_id=%s
    ]], player_id):gsub("\n", "")
    log.verbose(query)
    for x in db:nrows(query) do
        skills[x.skill_id] = {
            level = x.level,
            experience = x.experience
        }
    end
    return skills
end

--- Save a single skill.
-- @param player_id Id of the player.
-- @param skill_id Id of the skill receiving the update.
-- @param level Value to set the level to.
-- @param experience Value to set the experience to.
function M.save_skill(player_id, skill_id, level, experience)
    local query = string.format([[
        UPDATE skills SET experience=%s, level=%s 
        WHERE player_id = %s
        AND skill_id=%s;
    ]], experience, 
        level, 
        player_id, 
        skill_id
    ):gsub("\n", "")
    log.verbose(query)
    db:exec(query)
end

--- Save all of a player's skills.
-- @param player_id Id of the player.
-- @param skills A table of the player's skills to save in the format:
--               {skill_id1 = {level = x, experience = x},
--                skill_id2 = {level = x, experience = x}}
function M.save_skills(player_id, skills)
    local sql = "UPDATE skills SET "
    local level_sql = "level = CASE skill_id "
    local exp_sql = "experience = CASE skill_id "
    local skill_ids = {}
    for k, v in pairs(skills) do
        level_sql = string.format("%s WHEN %s THEN %s ", level_sql, k, v.level)
        exp_sql = string.format("%s WHEN %s THEN %s ", exp_sql, k, v.experience)
        skill_ids[#skill_ids+1] = k
    end
    level_sql = level_sql .. "END, "
    exp_sql = exp_sql .. "END "
    sql = string.format([[
        %s %s %s
        WHERE player_id=%s
        AND skill_id IN (%s);
    ]], sql, level_sql, exp_sql, player_id, table.concat(skill_ids, ",")):gsub("\n", "")
    log.verbose(sql)
    db:exec(sql)
end

--- Get a sum of each player's skill levels.
-- The returned players are in descending order according to the
-- sum of their levels.
-- @return table Each player's rank in the form of:
--               {[1] = {name = "player1", rank = 10},
--                [2] = {name = "player2", rank = 8},
--                [3] = {name = "player3", rank = 3}}
function M.get_ranks()
    local query = string.gsub([[
        SELECT p.name AS name, SUM(s.level) AS rank
        FROM players p, skills s
        WHERE s.player_id = p.id
        GROUP BY s.player_id
        ORDER BY rank DESC;
    ]], "\n", "")
    log.verbose(query)
    local ranks = {}
    for x in db:nrows(query) do
        ranks[#ranks+1] = {name = x.name, rank = x.rank}
    end
    return ranks
end

--- Closes the database.
function M.close()
    log.action("Closing database")
    db:close()
end

return M
