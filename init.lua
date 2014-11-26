local modpath = minetest.get_modpath(minetest.get_current_modname())
local worldpath = minetest.get_worldpath()
package.path = package.path .. ";" .. modpath .. "/?.lua"

local hooks = require("hooks")
local log = require("logger")

hooks.init(modpath, worldpath)

log.action("Loaded!")
