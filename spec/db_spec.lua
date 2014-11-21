describe("db", function()
    local sqlite
    local memdb
    local db
    local name

    setup(function()
        sqlite = require("lsqlite3")
        db = require("db")
    end)

    teardown(function()
        sqlite = nil
        db = nil
    end)

    before_each(function()
        name = "testplayer"
        memdb = sqlite.open_memory()
        db.init(".", nil, memdb)
    end)

    after_each(function()
        db.close()
    end)

    describe("save_skills", function()
        it("should persist all skills to the database", function()
            local sql = string.format([[
                INSERT INTO players (name) VALUES ('%s');
                INSERT INTO skills (player_id, skill_id, level, experience)
                    SELECT p.id, 1, 1, 0
                    FROM players p
                    WHERE p.name='%s';
                INSERT INTO skills (player_id, skill_id, level, experience)
                    SELECT p.id, 2, 1, 0
                    FROM players p
                    WHERE p.name='%s';
                INSERT INTO skills (player_id, skill_id, level, experience)
                    SELECT p.id, 3, 1, 0
                    FROM players p
                    WHERE p.name='%s';
                INSERT INTO skills (player_id, skill_id, level, experience)
                    SELECT p.id, 4, 1, 0
                    FROM players p
                    WHERE p.name='%s';
            ]], name, name, name, name, name)
            memdb:exec(sql)

            local skills = {
                [1] = {
                    experience = 100,
                    level = 1
                }, 
                [2] = {
                    experience = 200,
                    level = 2
                }, 
                [3] = {
                    experience = 300,
                    level = 3
                }, 
                [4] = {
                    experience = 400,
                    level = 4
                }
            }
            db.save_skills(name, skills)

            for i, v in ipairs(skills) do
                local found = false
                local sql = string.format([[
                    SELECT level, experience FROM skills
                    WHERE player_id IN (
                        SELECT player_id FROM players
                        WHERE name='%s'
                    )
                    AND skill_id=%s
                    ORDER BY skill_id ASC;
                ]], name, i)
                for x in memdb:nrows(sql) do
                    assert.are.same(skills[i], x)
                    found = true
                end
                assert.is_true(found)
            end
        end)
    end)
end)
