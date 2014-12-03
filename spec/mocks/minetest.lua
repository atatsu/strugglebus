local mock_player = require("player")

local M = {}

function M.log(level, msg) end

function M.setting_getbool(name) end

function M.setting_get(name) end

function M.chat_send_player(name, msg) end

function M.after(time, callback) end

function M.get_player_by_name(name)
    return mock_player
end

function M.register_on_joinplayer() end

function M.register_on_leaveplayer() end

function M.register_on_dignode() end

function M.register_chatcommand(cmd, cmd_def) end

function M.register_on_shutdown() end

function M.sound_play(sound_spec, sound_params) end

function M.check_player_privs(playername, privs)
    return false
end

return M
