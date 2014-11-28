local M = {}

local debug_mode = minetest.setting_getbool("mtmmo_debug_mode")
M.debug_mode = (debug_mode or false)

local hud_fade_time = minetest.setting_get("mtmmo_hud_fade_time")
M.hud_fade_time = tonumber((hud_fade_time or 10))

local database_name = minetest.setting_get("mtmmo_database_name")
M.database_name = (database_name or "mtmmo.sqlite3")

return M
