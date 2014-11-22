CREATE TABLE IF NOT EXISTS players (
    id INTEGER PRIMARY KEY, 
    name TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_players_name 
    ON players (name);

CREATE TABLE IF NOT EXISTS skills (
    id INTEGER PRIMARY KEY,
    player_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    level INTEGER NOT NULL,
    experience INTEGER NOT NULL,
    FOREIGN KEY(player_id) REFERENCES players(id)
);
