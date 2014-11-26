describe("db", function()
    local sqlite
    local memdb
    local db
    local name
    local constants

    setup(function()
        sqlite = require("lsqlite3")
        db = require("db")
        constants = require("constants")
    end)

    teardown(function()
        sqlite = nil
        db = nil
        package.loaded["db"] = nil
        constants = nil
        package.loaded["constants"] = nil
    end)

    before_each(function()
        name = "testplayer"
        memdb = sqlite.open_memory()
        db.init(".", nil, memdb)
    end)

    after_each(function()
        db.close()
    end)

    describe("add_player", function()
        it("should simply return the player's id if they're already in the database", function()
            local sql = string.format("INSERT INTO players (name) VALUES ('%s');", name)
            memdb:exec(sql)
            local id = db.add_player(name)
            assert.are.equals(1, id)
        end)

        it("should add the player to the `players` table if they dont' yet exist", function()
            local id = db.add_player(name)
            assert.are_not.equals(nil, id)
            local found_id
            local query = string.format("SELECT id FROM players WHERE name='%s';", name)
            memdb:exec(query, function(udata, cols, values, names)
                found_id = tonumber(values[1])
                return 0
            end)
            assert.are.equals(id, found_id)
        end)

        it("should initialize the player's skills when they are newly added", function()
            local id = db.add_player(name)
            local actual = {}
            local query = string.format([[
                SELECT skill_id, level, experience 
                FROM skills 
                WHERE player_id=%s
                ORDER BY skill_id ASC
            ]], id)
            for x in memdb:nrows(query) do
                actual[x.skill_id] = {
                    experience = x.experience,
                    level = x.level
                }
            end
            local expected = {}
            for i, k in ipairs(constants.SKILLS) do
                expected[i] = {
                    experience = 0,
                    level = 1
                }
            end
            assert.are.same(expected, actual)
        end)
    end)

    describe("save_skill", function()
        it("should update the specified skill with the supplied values", function()
            local id = db.add_player(name)
            local expected_level = 20
            local expected_exp = 3000
            db.save_skill(id, constants.DIGGING, expected_level, expected_exp)
            local query = string.format(
                "SELECT level, experience FROM skills WHERE player_id=%s AND skill_id=%s;",
                id, 
                constants.DIGGING
            )
            local actual_level
            local actual_exp
            memdb:exec(query, function(udata, cols, values, names)
                actual_level = tonumber(values[1])
                actual_exp = tonumber(values[2])
            end)
            assert.are.equals(expected_level, actual_level)
            assert.are.equals(expected_exp, actual_exp)
        end)
    end)

    describe("save_skills", function()
        local expected = {
            [constants.DIGGING] = {experience = 100, level = 1}, 
            [constants.MINING] = {experience = 200, level = 2}, 
            [constants.LUMBERJACKING] = {experience = 300, level = 3}, 
            [constants.CULTIVATING] = {experience = 400, level = 4}
        }

        it("should persist all skills to the database given the player's id", function()
            local id = db.add_player(name)
            db.save_skills(id, expected)
            local actual = {}
            local query = string.format(
                "SELECT skill_id, level, experience FROM skills WHERE player_id=%s",
                id
            )
            for x in memdb:nrows(query) do
                actual[x.skill_id] = {level = x.level, experience = x.experience}
            end
            assert.are.same(expected, actual)
        end)
    end)

    describe("load_skills", function()
        local expected = {
            [constants.DIGGING] = {experience = 100, level = 1}, 
            [constants.MINING] = {experience = 200, level = 2}, 
            [constants.LUMBERJACKING] = {experience = 300, level = 3}, 
            [constants.CULTIVATING] = {experience = 400, level = 4}
        }

        it("should return a table of the player's skills", function()
            local id = db.add_player(name)
            db.save_skills(id, expected)
            local actual = db.load_skills(id)
            assert.are.same(expected, actual)
        end)
    end)
end)
