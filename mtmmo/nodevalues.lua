local constants = require("constants")

local M = {
    -- {{{ Digging `default`
    ["default:dirt_with_grass"] = {constants.DIGGING, 5},
    ["default:dirt"] = {constants.DIGGING, 5},
    ["default:dirt_with_grass_footsteps"] = {constants.DIGGING, 5},
    ["default:dirt_with_snow"] = {constants.DIGGING, 5},
    ["default:sand"] = {constants.DIGGING, 5},
    ["default:desert_sand"] = {constants.DIGGING, 5},
    ["default:gravel"] = {constants.DIGGING, 7},
    ["default:clay"] = {constants.DIGGING, 10},
    -- }}}
    -- {{{ Digging `farming`
    ["farming:soil"] = {constants.DIGGING, 5},
    ["farming:soil_wet"] = {constants.DIGGING, 5},
    ["farming:desert_sand_soil"] = {constants.DIGGING, 5},
    ["farming:desert_sand_soil_wet"] = {constants.DIGGING, 5},
    -- }}}

    -- {{{ Mining `default`
    ["default:stone"] = {constants.MINING, 5},
    ["default:desert_stone"] = {constants.MINING, 6},
    ["default:stone_with_coal"] = {constants.MINING, 10},
    ["default:stone_with_iron"] = {constants.MINING, 13},
    ["default:stone_with_copper"] = {constants.MINING, 15},
    ["default:stone_with_mese"] = {constants.MINING, 20},
    ["default:stone_with_gold"] = {constants.MINING, 17},
    ["default:stone_with_diamond"] = {constants.MINING, 30},
    ["default:sandstone"] = {constants.MINING, 7},
    ["default:obsidian"] = {constants.MINING, 20},
    -- }}}

    -- {{{ Lumberjacking `default`
    ["default:tree"] = {constants.LUMBERJACKING, 5},
    ["default:jungletree"] = {constants.LUMBERJACKING, 10},
    ["default:cactus"] = {constants.LUMBERJACKING, 7},
    -- }}}
    
    -- {{{ Cultivating `default`
    ["default:grass_5"] = {constants.CULTIVATING, 1},
    ["default:papyrus"] = {constants.CULTIVATING, 5},
    ["default:junglegrass"] = {constants.CULTIVATING, 3},
    ["default:apple"] = {constants.CULTIVATING, 4},
    -- }}}
    -- {{{ Cultivating `farming`
    ["farming:wheat_8"] = {constants.CULTIVATING, 15},
    ["farming:cotton_8"] = {constants.CULTIVATING, 15},
    ["farming:potato_4"] = {constants.CULTIVATING, 10},
    ["farming:raspberry_4"] = {constants.CULTIVATING, 10},
    ["farming:rhubarb_3"] = {constants.CULTIVATING, 8},
    ["farming:corn_8"] = {constants.CULTIVATING, 15},
    ["farming:tomato_8"] = {constants.CULTIVATING, 15},
    ["farming:carrot_8"] = {constants.CULTIVATING, 15},
    ["farming:coffee_5"] = {constants.CULTIVATING, 13},
    ["farming:cucumber_4"] = {constants.CULTIVATING, 10},
    ["farming:blueberry_4"] = {constants.CULTIVATING, 10},
    ["farming:melon_8"] = {constants.CULTIVATING, 15},
    ["farming:pumpkin"] = {constants.CULTIVATING, 10},
    -- }}}
    -- {{{ Cultivating `flowers`
    ["flowers:dandelion_white"] = {constants.CULTIVATING, 3},
    ["flowers:dandelion_yellow"] = {constants.CULTIVATING, 3},
    ["flowers:geranium"] = {constants.CULTIVATING, 3},
    ["flowers:rose"] = {constants.CULTIVATING, 3},
    ["flowers:tulip"] = {constants.CULTIVATING, 3},
    ["flowers:viola"] = {constants.CULTIVATING, 3},
    -- }}}
}

--[[
["default:jungleleaves"] = {constants., 10},
["default:leaves"] = {constants., 10},
["default:dry_shrub"] = {constants., 10},
["default:ice"] = {constants., 10},
["default:snow"] = {constants., 10},

["default:wood"] = {constants., 10},
["default:cloud"] = {constants., 10},
["default:water_flowing"] = {constants., 10},
["default:water_source"] = {constants., 10},
["default:lava_flowing"] = {constants., 10},
["default:lava_source"] = {constants., 10},
["default:cobble"] = {constants., 10},
["default:desert_cobble"] = {constants., 10},
["default:mossycobble"] = {constants., 10},
--]]

return M
