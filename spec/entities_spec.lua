describe("entities", function()

    local entities
    local mock_mt
    local mock_player

    setup(function()
        mock_player = {
            hud_add = function(hud_def) 
                return "testhudid"
            end,
            hud_change = function(id, stat, value) end,
        }
        mock_mt = {
            setting_getbool = function(name) end,
            setting_get = function(name) end,
            log = function() end,
            chat_send_player = function(name, msg) end,
            get_player_by_name = function(name)
                return mock_player
            end, 
            after = function(time, callback) end
        }
        _G.minetest = mock_mt
        entities = require("entities")
    end)

    teardown(function()
        mock_player = nil
        mock_mt = nil
        _G.minetest = nil
        entities = nil
        package.loaded["entities"] = nil
    end)

    describe("MMOPlayer", function()

        local skills
        local db
        local mock_db

        setup(function()
            db = require("db")
            mock_db = mock(db, true)
        end)

        teardown(function()
            db = nil
            package.loaded["db"] = nil
            mock_db = nil
        end)

        describe("when created", function()

            local mmoplayer

            before_each(function()
                stub(mock_player, "hud_add")
                mmoplayer = entities.MMOPlayer("testplayer", mock_db)
            end)

            after_each(function()
                mock_player.hud_add:revert()
                mmoplayer = nil
            end)

            it("when created should set its name", function()
                assert.are.equal("testplayer", mmoplayer.name)
            end)

            it("should add the player to the database", function()
                assert.stub(mock_db.add_player).was.called_with("testplayer")
            end)

            it("should load up the player's skills", function()
                --assert.stub(mock_db.load_skills).was.called_with(10)
                assert.stub(mock_db.load_skills).was.called()
            end)

            it("should setup a hud for the player", function()
                assert.stub(mock_player.hud_add).was.called(1)
            end)
        end)

        describe("update_hud", function()

            local mmoplayer

            before_each(function()
                stub(mock_player, "hud_change")
                stub(mock_mt, "after")
                mmoplayer = entities.MMOPlayer("testplayer", mock_db)
            end)

            after_each(function()
                mock_player.hud_change:revert()
                mock_mt.after:revert()
                mmoplayer = nil
            end)

            it("should update the hud with specified text", function()
                mmoplayer:update_hud("update me!")
                --assert.are.equal("testhudid", mock_player.hud_change.calls[1][2])
                --assert.are.equal("text", mock_player.hud_change.calls[1][3])
                --assert.are.equal("update me!", mock_player.hud_change.calls[1][4])
                assert.stub(mock_player.hud_change).was.called_with(
                    mock_player, "testhudid", "text", "update me!"
                )
            end)

            it("should clear the hud text if a fade_time is specified", function()
                mmoplayer:update_hud("update me!", 5)
                assert.are.equal(5, mock_mt.after.calls[1][1])
                local callback = mock_mt.after.calls[1][2]
                callback()
                assert.stub(mock_player.hud_change).was.called_with(
                    mock_player, "testhudid", "text", ""
                )
            end)

        end)

        describe("node_dug", function()

            local constants
            local nodevalues
            local mmoplayer
            local skills

            setup(function()
                constants = require("constants")
                nodevalues = require("nodevalues")
            end)

            teardown(function()
                nodevalues = nil
                package.loaded["nodevalues"] = nil
                constants = nil
                package.loaded["constants"] = nil
            end)

            before_each(function()
                stub(mock_mt, "chat_send_player")
                skills = {
                    [constants.DIGGING] = {level = 1, experience = 50},
                    [constants.MINING] = {level = 2, experience = 190},
                }
                mmoplayer = entities.MMOPlayer("testplayer", mock_db)
                mmoplayer.id = 10
                mmoplayer.skills = skills
            end)

            after_each(function()
                mock_mt.chat_send_player:revert()
                skills = nil
                mmoplayer = nil
            end)

            it("should apply experience to the appropriate skill", function()
                local nodevalue = nodevalues[constants.DIGGING]["default:dirt"]
                local new_value = nodevalue + skills[constants.DIGGING].experience
                mmoplayer:node_dug("default:dirt")
                assert.are.equal(new_value, mmoplayer.skills[constants.DIGGING].experience)
            end)

            it("should level the skill if current exp >= 100 * current level", function()
                mmoplayer:node_dug("default:stone")
                assert.are.equal(3, mmoplayer.skills[constants.MINING].level)
            end)

            it("should reset the experience in a leveled skill to 0", function()
                mmoplayer:node_dug("default:stone")
                assert.are.equal(0, mmoplayer.skills[constants.MINING].experience)
            end)

            it("should save a skill's stats if a level is gained", function()
                mmoplayer:node_dug("default:stone")
                assert.stub(mock_db.save_skill).was.called_with(
                    mmoplayer.id, 
                    constants.MINING, 
                    mmoplayer.skills[constants.MINING].level,
                    mmoplayer.skills[constants.MINING].experience
                )
            end)

            it("should notify a player of a leveled skill", function()
                mmoplayer:node_dug("default:stone")
                local expected_msg = string.format(
                    "You gained a level in %s! (%s)",
                    constants.SKILLS[constants.MINING],
                    mmoplayer.skills[constants.MINING].level
                )
                --assert.are.equal("testplayer", mock_mt.chat_send_player.calls[1][1])
                --assert.are.equal(expected_msg, mock_mt.chat_send_player.calls[1][2])
                assert.stub(mock_mt.chat_send_player).was.called_with(
                    "testplayer", 
                    expected_msg
                )
            end)
            
        end)

        describe("save_skills", function()

            local mmoplayer

            before_each(function()
                mmoplayer = entities.MMOPlayer("testplayer", mock_db)
            end)

            after_each(function()
                mmoplayer = nil
            end)

            it("should save the player's skills to the database", function()
                local skills = {
                    {level = 1, experience = 100},
                    {level = 2, experience = 200}
                }
                mmoplayer.id = 10
                mmoplayer.skills = skills
                mmoplayer:save_skills()
                assert.stub(mock_db.save_skills).was.called_with(10, skills)
            end)
        end)
    end)
end)
