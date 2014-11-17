local skills = {
    "digging",
    "mining",
    "lumberjacking"
}

local Player = {}
Player.__index = Player

setmetatable(Player, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function Player.new(name, db)
    local self = setmetatable({}, Player)
    self.name = name
    self.db = db
    if not self.db.add_player(self.name) then
        -- player didn't yet exist so we also need to initialize their skills
        self.db.initialize_skills(self.name, skills)
    end
    -- load up the skills
    self.skills = self.db.load_skills(self.name)
    return self
end

return Player
