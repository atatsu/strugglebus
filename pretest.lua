-- for some reason --lpath isn't working so this is a workaround
package.path = package.path .. ";" .. "./mtmmo/?.lua"
package.path = package.path .. ";" .. "./spec/mocks/?.lua"
local minetest = require("minetest")
_G.minetest = minetest
