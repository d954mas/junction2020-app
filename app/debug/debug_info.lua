local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local JSON = require "libs_project.json"
local SHARED = require "libs_project.shared"

local IGNORE_CONTEXTS = {
	["actions_capability_account_linking"] = true,
	["actions_capability_audio_output"] = true,
	["actions_capability_custom_stage"] = true,
	["actions_capability_interactive_canvas"] = true,
	["actions_capability_media_response_audio"] = true,
	["actions_capability_screen_output"] = true,
	["google_assistant_input_type_voice"] = true,
	["google_assistant_welcome "] = true,
}

local M = {}

M.entities = 0
M.tts_playing = false
M.storage_info = ""
M.response_last = ""
M.contexts = ""
M.version = "1"
M.server = "dev"
M.version_time = "0/0/0"
M.cheatsEnabled = false
M.time_server = 0
M.time_client_delta = 0
M.time = 0
M.speech_recognition = ""
M.start_speech_time = 0
M.start_shared_time = 0
M.speech_shared_dt_time = 0
M.dialog = {}

M.google = {
	listening_mode = "",
	phrase_matched = "",
}

function M.init()
end

function M.update_storage_info()
	M.storage_info = "Storage:" .. JSON.json_haxe(SPEECH.shared.world.storage, true)
end

function M.update_contexts()
	local keys = SPEECH.shared.world.contexts:keys()
	local contexts = ""
	while (keys:hasNext()) do
		local key = keys:next()
		local value = SPEECH.shared.world.contexts.h[key]
		if not IGNORE_CONTEXTS[key] then
			contexts = contexts .. string.format("%s(%d){%s}\n", value.name, value.lifespan, JSON.encode(value.parameters))
		end
	end
	M.contexts = "Contexts:\n" .. contexts
end

function M.sharedLoaded()
	M.version = SPEECH.shared.world.storage.version.version
	M.server = SPEECH.shared.world.storage.version.server
	M.version_time = SPEECH.shared.world.storage.version.time
end

function M.update_frame()
    M.start_shared_time = SPEECH.start_shared_time or 0
    M.start_speech_time = SPEECH.start_speech_time or 0
    M.speech_shared_dt_time = M.start_speech_time - M.start_shared_time
end

function M.update(dt)
	M.tts_playing = SPEECH.tts_playing
	if SPEECH.shared then
		M.cheatsEnabled = SPEECH.shared.world.storage.profile.cheatsEnabled
		M.time_server = SHARED.shared.project.utils.TimeUtils.timeToStringShort(SPEECH.shared.world.storage.timers.serverLastTime)
		M.time_client_delta = SPEECH.shared.world.storage.timers.clientDeltaTime
		M.time = SPEECH.shared.world.storage.timers.time > 0 and SHARED.shared.project.utils.TimeUtils.timeToStringShort(SPEECH.shared.world.storage.timers.time) or 0

	end
end

function M.conv_client_say(text)
	table.insert(M.dialog, { type = "client", text = tostring(text) })
end
function M.conv_server_say(text)
	table.insert(M.dialog, { type = "servet", text = tostring(text) })
end

function M.conv_response(response)
	local data = {
		intent = response.intent,
		response = response.response
	}
	M.response_last = "Response:" .. JSON.encode(data, true)
end

return M