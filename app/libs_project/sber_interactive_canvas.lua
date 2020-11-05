local INTENTS = require("libs_project.intents")
local COMMON = require "libs.common"
local CONSTANTS = require "libs.constants"
local FakeConv = require "libs_project.fake_conversation"
local Shared = require "libs_project.shared"
local NativeApi = require "libs_project.native_api"
local JSON = require "libs_project.json"
local Words = require "libs_project.words"

local M = {}

function M.register(listener)
	assert(interactive_canvas_sber, "no sber canvas")
	interactive_canvas = {
		init = function()
			jstodef.add_listener(listener)
			interactive_canvas_sber.init()
		end,
		send_request = function(...)
			assert("not impl")
		end,
		send_text_query = function(text)
			local json = JSON.encode({ action_id = "TextQuery", parameters = { text = text } })
			interactive_canvas_sber.send_text_query(json)
		end,
		listener_register = function(...)

		end,
		listener_remove = function(...)

		end,
		exit = function(...)
			interactive_canvas_sber.exit()
		end,
		can_send = function()
			interactive_canvas_sber.can_send()
		end
	}
end

return M



