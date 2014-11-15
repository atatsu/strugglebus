local sqlite = require("lsqlite3")

local modpath
local worldpath
local db
local memdb

local mod = {}

function mod.init(_modpath, _worldpath)
    modpath = _modpath
    worldpath = _worldpath
    db = sqlite.open(worldpath .. "/mtmmo.sqlite3")
    memdb = sqlite.open_memory()

    -- create tables we'll be using
    minetest.log("action", "[mtmmo] -- Creating tables")
    local file = io.open(modpath .. "/sql/tables.sql", "r")
    local sql = file:read("*a")
    file:close()
    db:exec(sql)
end

function mod.add_player(name)
    local id
    for x in db:nrows("SELECT id FROM players WHERE name='" .. name .. "'") do
        id = x.id
    end

    if not id then
        db:exec("INSERT INTO players (name) VALUES ('" .. name .. "')")
    end
end

function mod.close()
    minetest.log("action", "[mtmmo] -- Closing database")
    db:close()
    memdb:close()
end

return mod
