local constants = require("constants")

local M = {
    -- {{{ Digging `default`
    ["default:dirt_with_grass"] = {constants.DIGGING, 10},
    ["default:dirt"] = {constants.DIGGING, 10},
    ["default:dirt_with_grass_footsteps"] = {constants.DIGGING, 10},
    ["default:dirt_with_snow"] = {constants.DIGGING, 10},
    ["default:sand"] = {constants.DIGGING, 10},
    ["default:desert_sand"] = {constants.DIGGING, 10},
    ["default:gravel"] = {constants.DIGGING, 10},
    ["default:clay"] = {constants.DIGGING, 10},
    -- }}}
    -- {{{ Digging `farming`
    ["farming:soil"] = {constants.DIGGING, 10},
    ["farming:soil_wet"] = {constants.DIGGING, 10},
    ["farming:desert_sand_soil"] = {constants.DIGGING, 10},
    ["farming:desert_sand_soil_wet"] = {constants.DIGGING, 10},
    -- }}}

    -- {{{ Mining `default`
    ["default:stone"] = {constants.MINING, 10},
    ["default:desert_stone"] = {constants.MINING, 10},
    ["default:stone_with_coal"] = {constants.MINING, 10},
    ["default:stone_with_iron"] = {constants.MINING, 10},
    ["default:stone_with_copper"] = {constants.MINING, 10},
    ["default:stone_with_mese"] = {constants.MINING, 10},
    ["default:stone_with_gold"] = {constants.MINING, 10},
    ["default:stone_with_diamond"] = {constants.MINING, 10},
    ["default:sandstone"] = {constants.MINING, 10},
    ["default:obsidian"] = {constants.MINING, 10},
    -- }}}

    -- {{{ Lumberjacking `default`
    ["default:tree"] = {constants.LUMBERJACKING, 10},
    ["default:jungletree"] = {constants.LUMBERJACKING, 10},
    ["default:cactus"] = {constants.LUMBERJACKING, 10},
    -- }}}
    
    -- {{{ Cultivating `default`
    ["default:grass_1"] = {constants.CULTIVATING, 10},
    ["default:papyrus"] = {constants.CULTIVATING, 10},
    ["default:junglegrass"] = {constants.CULTIVATING, 10},
    -- }}}
    -- {{{ Cultivating `flowers`
    ["flowers:dandelion_white"] = {constants.CULTIVATING, 10},
    ["flowers:dandelion_yellow"] = {constants.CULTIVATING, 10},
    ["flowers:geranium"] = {constants.CULTIVATING, 10},
    ["flowers:rose"] = {constants.CULTIVATING, 10},
    ["flowers:tulip"] = {constants.CULTIVATING, 10},
    ["flowers:viola"] = {constants.CULTIVATING, 10},
    -- }}}
}

--[[
["default:jungleleaves"] = {constants., 10},
["default:leaves"] = {constants., 10},
["default:dry_shrub"] = {constants., 10},
["default:ice"] = {constants., 10},
["default:snow"] = {constants., 10},

["fire:basic_flame"] = {constants., 10},
["tnt:tnt"] = {constants., 10},
["tnt:tnt_burning"] = {constants., 10},
["tnt:boom"] = {constants., 10},
["tnt:gunpowder"] = {constants., 10},
["tnt:gunpowder_burning"] = {constants., 10},
["vessels:glass_bottle"] = {constants., 10},
["vessels:drinking_glass"] = {constants., 10},
["vessels:steel_bottle"] = {constants., 10},
["default:stonebrick"] = {constants., 10},
["default:desert_stonebrick"] = {constants., 10},
["default:sandstonebrick"] = {constants., 10},
["default:brick"] = {constants., 10},
["default:junglewood"] = {constants., 10},
["default:junglesapling"] = {constants., 10},
["default:bookshelf"] = {constants., 10},
["default:glass"] = {constants., 10},
["default:fence_wood"] = {constants., 10},
["default:rail"] = {constants., 10},
["default:ladder"] = {constants., 10},
["default:wood"] = {constants., 10},
["default:cloud"] = {constants., 10},
["default:water_flowing"] = {constants., 10},
["default:water_source"] = {constants., 10},
["default:lava_flowing"] = {constants., 10},
["default:lava_source"] = {constants., 10},
["default:torch"] = {constants., 10},
["default:sign_wall"] = {constants., 10},
["default:chest"] = {constants., 10},
["default:chest_locked"] = {constants., 10},
["default:furnace"] = {constants., 10},
["default:furnace_active"] = {constants., 10},
["default:cobble"] = {constants., 10},
["default:desert_cobble"] = {constants., 10},
["default:mossycobble"] = {constants., 10},
["default:coalblock"] = {constants., 10},
["default:steelblock"] = {constants., 10},
["default:copperblock"] = {constants., 10},
["default:bronzeblock"] = {constants., 10},
["default:mese"] = {constants., 10},
["default:goldblock"] = {constants., 10},
["default:diamondblock"] = {constants., 10},
["default:obsidian_glass"] = {constants., 10},
["default:nyancat"] = {constants., 10},
["default:nyancat_rainbow"] = {constants., 10},
["default:sapling"] = {constants., 10},
["default:apple"] = {constants., 10},
["default:snowblock"] = {constants., 10},
["doors:trapdoor"] = {constants., 10},
["doors:trapdoor_open"] = {constants., 10},
--]]

return M
