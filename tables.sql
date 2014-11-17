CREATE TABLE IF NOT EXISTS players (
    id INTEGER PRIMARY KEY, 
    name TEXT
);

CREATE TABLE IF NOT EXISTS skills (
    id INTEGER PRIMARY KEY,
    player_id INTEGER,
    skill_id INTEGER,
    level INTEGER,
    experience INTEGER,
    FOREIGN KEY(player_id) REFERENCES players(id)
);
