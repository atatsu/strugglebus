describe("hooks", function()
    local hooks
    local mock_mt
    local entities
    local MMOPlayer
    local mock_player
    local settings

    setup(function()
        mock_mt = require("minetest")
        mock_player = require("player")
        entities = require("entities")
        MMOPlayer = entities.MMOPlayer
    end)

    teardown(function()
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

        setup(function()
            stub(mock_mt, "register_on_joinplayer")
            stub(mock_mt, "register_on_leaveplayer")
            stub(mock_mt, "register_on_dignode")
            stub(mock_mt, "register_chatcommand")
            stub(mock_mt, "register_on_shutdown")
        end)

        teardown(function()
            mock_mt.register_on_joinplayer:revert()
            mock_mt.register_on_leaveplayer:revert()
            mock_mt.register_on_dignode:revert()
            mock_mt.register_chatcommand:revert()
            mock_mt.register_on_shutdown:revert()
        end)

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
                    params = "<command> (Use '/mtmmo help' for more info)",
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
            --hooks.mmoplayers["testplayer"] = nil
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

        describe("when supplied with 'help'", function()

            it("and an unknown subcommand should return general help text", function()
                local success, message = hooks._process_chatcommand("testplayer", "help notacommand")
                assert.is_true(success)
                assert.are.equal(constants.HELP.help, message)
            end)

            it("should return the general help text", function()
                local success, message = hooks._process_chatcommand("testplayer", "help")
                assert.is_true(success)
                assert.are.equal(constants.HELP.help, message)
            end)

            it("and 'skills' should return the help text for the 'skills' subcommand", function()
                local success, message = hooks._process_chatcommand("testplayer", "help skills")
                assert.is_true(success)
                assert.are.equal(constants.HELP.skills, message)
            end)

            it("and 'ranks' should return the help text for the 'rank' subcommand", function()
                local success, message = hooks._process_chatcommand("testplayer", "help ranks")
                assert.is_true(success)
                assert.are.equal(constants.HELP.ranks, message)
            end)

        end)

        describe("when supplied with 'skills'", function()

            it("should update the player's HUD with all their skills", function()
                stub(MMOPlayer, "update_hud")
                local success = hooks._process_chatcommand("testplayer", "skills")
                assert.is_true(success)
                local expected_text = "Skills\nName: Level (Experience)\n========================\n"
                for i, v in ipairs(skills) do
                    expected_text = string.format(
                        "%s%s: %s (%s)\n", 
                        expected_text, 
                        constants.SKILLS[i], 
                        v.level, 
                        v.experience
                    )
                end
                assert.stub(MMOPlayer.update_hud).was.called(1)
                --assert.are.equal(expected_text, MMOPlayer.update_hud.calls[1][2]) -- [1][1] is the stub itself
                --assert.are.equal(5, MMOPlayer.update_hud.calls[1][3])
                assert.stub(MMOPlayer.update_hud).was.called_with(
                    MMOPlayer, 
                    expected_text, 
                    settings.hud_fade_time
                )
                MMOPlayer.update_hud:revert()
            end)

        end)

        describe("when supplied with 'ranks'", function()

            local db

            before_each(function()
                db = require("db")
                -- monkey patching isn't very desirable, but oh well
                db.get_ranks = function()
                    return {
                        {name = "testplayer2", rank = 16},
                        {name = "testplayer1", rank = 8},
                        {name = "testplayer3", rank = 4}
                    }
                end
                spy.on(db, "get_ranks")
                stub(MMOPlayer, "update_hud")
            end)

            after_each(function()
                db = nil
                package.loaded["db"] = nil
                MMOPlayer.update_hud:revert()
            end)

            it("should get a list of all player's level totals from the database", function()
                local success = hooks._process_chatcommand("testplayer", "ranks")
                assert.spy(db.get_ranks).was.called(1)
            end)

            it("should output ranks to the player that issued the command", function()
                local expected_text = "Ranks\nName: Rank\n==========\n"
                expected_text = expected_text .. "testplayer2: 16\ntestplayer1: 8\ntestplayer3: 4\n"
                stub(MMOPlayer, "update_hud")
                local success = hooks._process_chatcommand("testplayer", "ranks")
                --assert.are.equal(expected_text, MMOPlayer.update_hud.calls[1][2])
                assert.stub(MMOPlayer.update_hud).was.called_with(
                    MMOPlayer,
                    expected_text,
                    settings.hud_fade_time
                )
                MMOPlayer.update_hud:revert()
            end)

        end)
    end)
end)
