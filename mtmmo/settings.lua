local M = {}

local debug_mode = minetest.setting_getbool("mtmmo_debug_mode")
M.debug_mode = (debug_mode or false)

-- Controls the number of seconds that informative HUDs are displayed
-- on screen (for instance when running `mtmmo skills`).
-- Default: `10`
local hud_fade_time = minetest.setting_get("mtmmo_hud_fade_time")
M.hud_fade_time = tonumber((hud_fade_time or 10))

-- Name to give the database file that is created in the world's
-- directory. 
-- Default: `mtmmo.sqlite3`
local database_name = minetest.setting_get("mtmmo_database_name")
M.database_name = (database_name or "mtmmo.sqlite3")

return M
