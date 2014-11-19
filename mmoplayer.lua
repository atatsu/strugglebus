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

function MMOPlayer:update_stats(node_name)
end

return MMOPlayer
