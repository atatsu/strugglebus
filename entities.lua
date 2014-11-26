local constants = require("constants")
local unitvalues = require("unitvalues")

local M = {}

local MMOPlayer = {}
MMOPlayer.__index = MMOPlayer

setmetatable(MMOPlayer, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function MMOPlayer.new(name, db)
    local self = setmetatable({}, MMOPlayer)
    self.name = name
    self._db = db
    self.id = self._db.add_player(self.name)
    -- load up the skills from the database
    self.skills = self._db.load_skills(self.id)
    -- setup a hud to use for displaying various stats
    self._player = minetest.get_player_by_name(name)
    self._hud = self._player:hud_add({
        hud_elem_type = "text",
        position = {x=1, y=0},
        offset = {x=-100, y=50},
        alignment = {x=0, y=1},
        number = 0xFFFFFF,
        text = ""
    })
    return self
end

function MMOPlayer:update_hud(text, fade_time)
    self._player:hud_change(self._hud, "text", text)
    if fade_time then
        minetest.after(fade_time, function()
            self._player:hud_change(self._hud, "text", "")
        end)
    end
end

function MMOPlayer:node_dug(node_name)
    -- Check if the dug node is worth any experience and if
    -- so update the player's stats accordingly.
    -- Additionally, check to see if the player has enough experience 
    -- to warrant a rank up in whatever particular skill is being updated (if any).
    local exp
    local skill_id
    for k, v in pairs(unitvalues) do
        exp = v[node_name]
        if exp ~= nil then
            skill_id = k
            break
        end
    end

    if exp ~= nil then
        local skill = self.skills[skill_id]
        skill.experience = skill.experience + exp
        minetest.log(
            "verbose", 
            string.format(
                "[mtmmo] -- %s gained experience in %s, %s (%s)", 
                self.name, 
                constants.SKILLS[skill_id], 
                exp, 
                skill.experience
            )
        )
        if skill.experience >= skill.level * 100 then
            -- player's skill leveled, save skill and send a notification
            -- to the player informing them of the level gain
            skill.experience = skill.experience - skill.level * 100
            skill.level = skill.level + 1
            minetest.log(
                "verbose",
                string.format(
                    "[mtmmo] -- %s gained a level in %s, %s", 
                    self.name, 
                    constants.SKILLS[skill_id], 
                    skill.level 
                )
            )
            minetest.chat_send_player(
                self.name, 
                string.format(
                    "You gained a level in %s! (%s)", 
                    constants.SKILLS[skill_id],
                    skill.level
                )
            )
            self._db.save_skill(self.id, skill_id, skill.level, skill.experience)
        end
    end
end

function MMOPlayer:save_skills()
    minetest.log("verbose", string.format("[mtmmo] -- Saving skills for %s", self.name))
    self._db.save_skills(self.id, self.skills)
end

M.MMOPlayer = MMOPlayer

return M
