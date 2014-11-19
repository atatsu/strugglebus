local constants = require("constants")
local unitvalues = require("unitvalues")

local MMOPlayer = {}
MMOPlayer.__index = MMOPlayer

setmetatable(MMOPlayer, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function MMOPlayer.new(name, db)
    local self = setmetatable({}, MMOPlayer)
    self._name = name
    self._db = db
    if not self._db.add_player(self._name) then
        -- player didn't yet exist so we also need to initialize their skills
        self._db.initialize_skills(self._name)
    end
    -- load up the skills from the database
    self._skills = self._db.load_skills(self._name)
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

function MMOPlayer:skills()
    return self._skills
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
        local skill = self._skills[skill_id]
        skill.experience = skill.experience + exp
        minetest.log(
            "verbose", 
            string.format(
                "[mtmmo] -- %s gained experience in %s, %s (%s)", 
                self._name, 
                constants.SKILLS[skill_id], 
                exp, 
                skill.experience
            )
        )
        if skill.experience >= skill.level * 100 then
            skill.experience = skill.experience - skill.level * 100
            skill.level = skill.level + 1
            minetest.log(
                "verbose",
                string.format(
                    "[mtmmo] -- %s gained a level in %s, %s", 
                    self._name, 
                    constants.SKILLS[skill_id], 
                    skill.level 
                )
            )
            minetest.chat_send_player(
                self._name, 
                string.format(
                    "You gained a level in %s! (%s)", 
                    constants.SKILLS[skill_id],
                    skill.level
                )
            )
            -- TODO: update stats in db
        end
    end
end

return MMOPlayer
