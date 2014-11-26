describe("hooks", function()
    local hooks
    local mock_mt
    local entities
    local MMOPlayer
    local mock_player
    local settings

    setup(function()
        -- setup a mock player object (the player object that is returned
        -- by numerous `minetest` api calls
        mock_player = {}
        function mock_player:get_player_name()
            return "testplayer"
        end
        function mock_player:hud_add(stuff)
            return 1
        end

        -- setup a mock minetest object and add it to the globals table
        mock_mt = {
            register_on_joinplayer = function()end,
            register_on_leaveplayer = function()end,
            register_on_dignode = function()end,
            register_chatcommand = function(cmd, cmd_def)end,
            register_on_shutdown = function()end, 
            setting_getbool = function(name)return false end,
            setting_get = function(name)
                if name == "mtmmo_hud_fade_time" then
                    return 5
                end
            end
        }
        stub(mock_mt, "register_on_joinplayer")
        stub(mock_mt, "register_on_leaveplayer")
        stub(mock_mt, "register_on_dignode")
        stub(mock_mt, "register_chatcommand")
        stub(mock_mt, "register_on_shutdown")
        function mock_mt.get_player_by_name(name)
            return mock_player
        end
        _G.minetest = mock_mt

        entities = require("entities")
        MMOPlayer = entities.MMOPlayer
    end)

    teardown(function()
        _G.minetest = nil
        mock_mt = nil
        entities = nil
        package.loaded["entities"] = nil
        MMOPlayer = nil
        mock_player = nil
    end)

    before_each(function()
        hooks = require("hooks")
    end)

    after_each(function()
        hooks = nil
        package.loaded["hooks"] = nil
    end)

    describe("init", function()

        local db
        local mock_db

        before_each(function()
            db = require("db")
            mock_db = mock(db, true)
            hooks.init("modpath", "worldpath")
        end)

        after_each(function()
            db = nil
            package.loaded["db"] = nil
            mock_db = nil
        end)

        it("should initialize the db module", function()
            assert.stub(mock_db.init).was.called_with("modpath", "worldpath")
        end)

        it("should register on joinplayer", function()
            assert.stub(mock_mt.register_on_joinplayer).was.called_with(hooks._register_on_joinplayer)
        end)

        it("should register on leaveplayer", function()
            assert.stub(mock_mt.register_on_leaveplayer).was.called_with(hooks._register_on_leaveplayer)
        end)

        it("should register on dignode", function()
            assert.stub(mock_mt.register_on_dignode).was.called_with(hooks._register_on_dignode)
        end)

        it("should register on shutdown", function()
            assert.stub(mock_mt.register_on_shutdown).was.called_with(hooks._register_on_shutdown)
        end)

        it("should register chatcommand", function()
            assert.stub(mock_mt.register_chatcommand).was.called_with(
                "mtmmo",
                {
                    params = "<command>",
                    func = hooks._process_chatcommand
                }
            )
        end)

    end)

    describe("_register_on_joinplayer", function()

        local db
        local mock_db

        before_each(function()
            db = require("db")
            mock_db = mock(db, true)
        end)

        after_each(function()
            db = nil
            package.loaded["db"] = nil
            mock_db = nil
        end)

        it("should create a new MMOPlayer", function()
            stub(MMOPlayer, "new")
            hooks._register_on_joinplayer(mock_player)
            assert.stub(MMOPlayer.new).was.called_with("testplayer", mock_db)
            MMOPlayer.new:revert()
        end)

        it("should track the newly created MMOPlayer", function()
            hooks._register_on_joinplayer(mock_player)
            assert.are.equals(MMOPlayer, getmetatable(hooks.mmoplayers["testplayer"]))
        end)
    end)

    describe("_register_on_leaveplayer", function()

        before_each(function()
            hooks.mmoplayers["testplayer"] = MMOPlayer
            stub(MMOPlayer, "save_skills")
        end)

        after_each(function()
            hooks.mmoplayers["testplayer"] = nil
            MMOPlayer.save_skills:revert()
        end)

        it("should save the leaving player's skills", function()
            hooks._register_on_leaveplayer(mock_player)
            assert.stub(MMOPlayer.save_skills).was.called_with(MMOPlayer)
        end)

        it("should stop tracking the player", function()
            hooks._register_on_leaveplayer(mock_player)
            assert.are.equals(nil, hooks.mmoplayers["testplayer"])
        end)
    end)

    describe("_register_on_dignode", function()

        it("should inform the mmoplayer a node was dug", function()
            hooks.mmoplayers["testplayer"] = MMOPlayer
            stub(MMOPlayer, "node_dug")
            hooks._register_on_dignode({}, {name="dirt"}, mock_player)
            assert.stub(MMOPlayer.node_dug).was.called_with(MMOPlayer, "dirt")
            MMOPlayer.node_dug:revert()
        end)
    end)

    describe("_register_on_shutdown", function()

        local db
        local mock_db

        before_each(function()
            db = require("db")
            mock_db = mock(db, true)
            hooks.mmoplayers["testplayer"] = MMOPlayer
            stub(MMOPlayer, "save_skills")
            hooks._register_on_shutdown()
        end)

        after_each(function()
            db = nil
            package.loaded["db"] = nil
            mock_db = nil
            hooks.mmoplayers["testplayer"] = nil
            MMOPlayer.save_skills:revert()
        end)

        it("should save skills for all connected players", function()
            assert.stub(MMOPlayer.save_skills).was.called(1)
            assert.stub(MMOPlayer.save_skills).was.called_with(MMOPlayer)
        end)

        it("should close the database connection", function()
            assert.stub(mock_db.close).was.called(1)
        end)
    end)

    describe("_process_chatcommand", function()

        local settings
        local constants
        local skills

        before_each(function()
            settings = require("settings")
            constants = require("constants")
            skills = {
                [constants.DIGGING] = {level = 1, experience = 100},
                [constants.MINING] = {level = 2, experience = 200},
                [constants.LUMBERJACKING] = {level = 3, experience = 300},
                [constants.CULTIVATING] = {level = 4, experience = 400},
            }
            MMOPlayer.skills = skills
            hooks.mmoplayers["testplayer"] = MMOPlayer
        end)

        after_each(function()
            settings = nil
            package.loaded["settings"] = nil
            skills = nil
            MMOPlayer.skills = nil
            constants = nil
            package.loaded["constants"] = nil
            hooks.mmoplayers["testplayer"] = nil
        end)


        it("when supplied with an unknown command should return as much", function()
            local success, message = hooks._process_chatcommand("testplayer", "")
            assert.is_false(success)
            assert.are.equal("Invalid command: ", message)
        end)

        it("when supplied with an unknown subcommand should return as much", function()
            local success, message = hooks._process_chatcommand("testplayer", "notacommand")
            assert.is_false(success)
            assert.are.equal("Invalid subcommand: notacommand", message)
        end)

        it("when supplied with 'help' and an unknown subcommand should return general help text", function()
            local success, message = hooks._process_chatcommand("testplayer", "help notacommand")
            assert.is_true(success)
            assert.are.equal(constants.HELP.help, message)
        end)

        it("when supplied with 'help' should return the general help text", function()
            local success, message = hooks._process_chatcommand("testplayer", "help")
            assert.is_true(success)
            assert.are.equal(constants.HELP.help, message)
        end)

        it("when supplied with 'help skills' should return the help text for the 'skills' subcommand", function()
            local success, message = hooks._process_chatcommand("testplayer", "help skills")
            assert.is_true(success)
            assert.are.equal(constants.HELP.skills, message)
        end)

        it("when supplied with 'help rank' should return the help text for the 'rank' subcommand", function()
            local success, message = hooks._process_chatcommand("testplayer", "help rank")
            assert.is_true(success)
            assert.are.equal(constants.HELP.rank, message)
        end)

        it("when supplied with 'skills' should update the player's HUD with all their skills", function()
            stub(MMOPlayer, "update_hud")
            local success = hooks._process_chatcommand("testplayer", "skills")
            assert.is_true(success)
            local expected_text = "Skills\nName: Level (Experience)\n"
            expected_text = expected_text .. string.rep("=", expected_text:len() - 8) .. "\n"
            for i, v in ipairs(skills) do
                expected_text = string.format("%s%s: %s (%s)\n", expected_text, constants.SKILLS[i], v.level, v.experience)
            end
            assert.stub(MMOPlayer.update_hud).was.called(1)
            --assert.are.equal(expected_text, MMOPlayer.update_hud.calls[1][2]) -- [1][1] is the stub itself
            --assert.are.equal(5, MMOPlayer.update_hud.calls[1][3])
            assert.stub(MMOPlayer.update_hud).was.called_with(MMOPlayer, expected_text, settings.hud_fade_time)
            MMOPlayer.update_hud:revert()
        end)
    end)
end)
