local COMMON = require "libs.common"
local INTENTS = require "libs_project.intents"
local JSON = require "libs_project.json"
local TAG = "RestApiInteractiveCanvas"
local ANDROID = sys.get_sys_info().system_name == "Android"
local Canvas = COMMON.class("RestApiInteractiveCanvas")

function Canvas:initialize()
	self.listeners = {}
	self.idle = true
end

function Canvas:init()
	self.uuid = sys.load("monstrarium_uuid").uuid
	if (not self.uuid) then
		self.uuid = requiref("googleanalytics.internal.uuid")()
		sys.save("monstrarium_uuid", { uuid = self.uuid })
	end
end

function Canvas:send_text_query(text)

	assert(type(text) == "string")
	if self.idle then
		self.idle = false
		COMMON.d("StartRequest:" .. text, TAG)
		local data = {
			user = {
				locale = "en-US",
				lastSeen = "2020-03-29T17:38:17Z",
				userVerificationStatus = "VERIFIED",
				userStorage = JSON.encode({
					data = {
						user_id = self.uuid
					}
				})
			},
			conversation = {
				conversationId = "ABwppHGCVDxLNaHbG_9BLrxsr9NEsMtX0AXX7At6qB7jpzXqOMcuPL1ODoGnT1B3HpyCTLthp-FO",
				type = "ACTIVE",
				conversationToken = "{\"data\":{}}"
			},
			inputs = {
				{
					intent = "actions.intent.TEXT",
					rawInputs = { { inputType = "VOICE", query = text } },
					arguments = {
						{ name = "text", rawText = text, textValue = text },
					}
				}
			}
		}

		http.request("https://monstrarium-dev.herokuapp.com/rest_api_android", "POST", function(_, id, responce)
			self.idle = true
			if (responce.status == 200) then
				COMMON.d("get response:" .. responce.response,TAG)
				local resp = JSON.decode(responce.response)
				local items = resp.expectedInputs and resp.expectedInputs[1].inputPrompt.richInitialPrompt.items or
						resp.finalResponse.richResponse
				--if (resp.expectedInputs) then


					for _, item in ipairs(items) do
						if (item.htmlResponse) then
							self:response_send(item.htmlResponse.updatedState)
						elseif item.simpleResponse then
							if ANDROID then
								speech_recognition.tts(item.simpleResponse.ssml)
							end
						end
					end
				--end
			end

		end, nil, JSON.encode(data), { timeout = 15 })
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
			M.canvas:send_text_query("main.welcome", nil, true)
		end,
		send_request = function(...)
			M.canvas:send_text_query(...)
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
		end
	}
end

return M



