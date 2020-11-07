local INTENTS = require("libs_project.intents")
local COMMON = require "libs.common"
local CONSTANTS = require "libs.constants"
local FakeConv = require "libs_project.fake_conversation"
local Shared = require "libs_project.shared"
local NativeApi = require "libs_project.native_api"
local JSON = require "libs_project.json"
local Words = require "libs_project.words"

local TAG = "FakeInteractiveCanvas"

local Canvas = COMMON.class("FakeInteractiveCanvas")

function Canvas:initialize()
	self.listeners = {}
	self.idle = true
	self.delay_min = CONSTANTS.FAKE_CANVAS_DELAY.min
	self.delay_max =  CONSTANTS.FAKE_CANVAS_DELAY.max
	self.conv = FakeConv()
	self.native_api = NativeApi.FakeNativeApi(self.conv, function(data)
		self:response_send(data)
	end)
	self.words = Words(self.conv.user.locale)
end

function Canvas:init()
end

---@param text string
function Canvas:send_text_query(text)
	assert(text)
	print("send_text_query:" .. text)
	local DEBUG_INFO = requiref "debug.debug_info"
	DEBUG_INFO.conv_client_say(text)
	if (text:find("hero.select ") == 1 or text:find("hero/select ") == 1) then
		local parts = COMMON.string_split(text, " ")
		self:send_request("hero.select", { hero = parts[2] })
	elseif (text:find("level.spawn.unit ") == 1 or text:find("level/spawn/unit ") == 1) then
		local parts = COMMON.string_split(text, " ")
		self:send_request("level.spawn.unit", { unit = parts[2] })
	elseif (text:find("level.cast ") == 1 or text:find("level.cast ") == 1) then
		local parts = COMMON.string_split(text, " ")
		self:send_request("level.cast", { spell = parts[2] })
	else
		text = text:gsub("/", ".")
		self:send_request(text)
	end
end

function Canvas:send_request(intent, data, ignore_delay)
	assert(intent)
	if self.idle then
		self.idle = false
		COMMON.d("StartRequest:" .. intent .. " data:" .. JSON.encode(data), TAG)
		timer.delay(ignore_delay and 0 or COMMON.LUME.random(self.delay_min, self.delay_max) * COMMON.GLOBAL.speed_game, false, function()
			self.idle = true
			local storage, contexts = self.conv.jsons.storage, self.conv.jsons.contexts
			if not storage then
				storage = COMMON.LUME.clone_deep(self.conv.user.storage)
				storage.user = COMMON.LUME.clone_deep(self.conv.user)
				storage.user.storage = nil
				storage = JSON.encode(storage)
			end
			if not contexts then
				contexts = JSON.encode(self.conv:contexts_get_list())
			end
			local shared = Shared.shared.Shared.new(self.native_api, storage, contexts, false, false)
			shared:updateServerTime();
			if intent == INTENTS.INTENTS.BATTLE_USER_SAY_WORD then
				data.word_exist = self.words:word_exist(data.word)
			end

			if intent == INTENTS.INTENTS.BATTLE_BOOSTER_TOOLTIP then
				shared:inputSetBattleWords(self.words:get_data(shared.world.storage.battle.wordCurrent))
				shared:processIntent(intent, data)
			else
				shared:processIntent(intent, data)
			end

			COMMON.d("EndRequest:" .. intent, TAG)
		end)
		return true
	else
		COMMON.d("Can't request. Not in idle", TAG)
		return false
	end
end

function Canvas:listener_register(listener)
	self.listeners[listener] = listener
end
function Canvas:listener_remove(listener)
	self.listeners[listener] = nil
end

function Canvas:response_send(response)
	for _, listener in pairs(self.listeners) do
		listener(nil, INTENTS.MESSAGES.IC_ON_UPDATE, response)
	end
end

local M = {}

function M.register()
	M.canvas = Canvas()
	interactive_canvas = {
		init = function()
			M.canvas:init()
		end,
		send_request = function(...)
			M.canvas:send_request(...)
		end,
		send_text_query = function(...)
			M.canvas:send_text_query(...)
		end,
		listener_register = function(...)
			M.canvas:listener_register(...)
		end,
		listener_remove = function(...)
			M.canvas:listener_remove(...)
		end,
		can_send = function()
			return M.canvas.idle
		end,
		exit = function()

		end
	}
	M.canvas:send_request("main.welcome", nil, true)
end

return M



