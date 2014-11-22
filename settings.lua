local M = {}

local debug_mode = minetest ~= nil and minetest.setting_getbool("mtmmo_debug_mode") or nil
M.debug_mode = (debug_mode or false)

local hud_fade_time = minetest ~= nil and minetest.setting_get("mtmmo_hud_fade_time") or nil
M.hud_fade_time = tonumber((hud_fade_time or 10))

local database_name = minetest ~= nil and minetest.setting_get("mtmmo_database_name") or nil
M.database_name = (database_name or "mtmmo.sqlite3")

return M
