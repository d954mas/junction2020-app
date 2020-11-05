local COMMON = require "libs.common"
local FAKE_INTERACTIVE_CANVAS = require "libs_project.fake_interactive_canvas"
local REST_INTERACTIOVE_CANVAS = require "libs_project.rest_api_interactive_canvas"
local SBER_INTERACTIVE_CANVAS = require "libs_project.sber_interactive_canvas"
local INTENTS = require "libs_project.intents"
local GA = require "libs_project.google_analytics"
local Shared = require "libs_project.shared"
local TAG = "Speech"
local NativeApi = require "libs_project.native_api"
local JSON = require "libs_project.json"
local CONSTANTS = require "libs.constants"

local Speech = COMMON.class("[Speech]")

function Speech:initialize()
    ---@type SharedHaxe
    self.shared = nil
    self.tts_playing = false
    self.nativeApi = NativeApi.BaseNativeApi()
end

---@param world World
function Speech:set_world(world)
    self.world = world
end

function Speech:init()
    local time = os.clock()
    Shared.shared.Shared.load()
    pprint("time:" .. (os.clock() - time))
    if (COMMON.CONSTANTS.INTERACTIVE_CANVAS_SBERBANK) then
        self:create_listener_sber()
    else
        self:create_listener()
    end

    if (COMMON.CONSTANTS.FAKE_CANVAS) then
        FAKE_INTERACTIVE_CANVAS.register()
        interactive_canvas.init()
        interactive_canvas.listener_register(self.interactive_canvas_listener)
    elseif (COMMON.CONSTANTS.INTERACTIVE_CANVAS_SBERBANK) then
        SBER_INTERACTIVE_CANVAS.register(self.interactive_canvas_listener)
        interactive_canvas.init()
    elseif (COMMON.CONSTANTS.REST_CANVAS) then
        REST_INTERACTIOVE_CANVAS.register()
        if (sys.get_sys_info().system_name == "Android") then
            speech_recognition.init()
            speech_recognition.start()
            local debugInfo = requiref "debug.debug_info"
            speech_recognition.set_callback(function(_, msg, data)
                if msg ~= 3 then
                    --3 have a lot of spam
                    debugInfo.speech_recognition = data.result
                end
                if msg == 2 then
                    debugInfo.speech_recognition = data.result
                    if (data.result) then
                        interactive_canvas.send_text_query(data.result)
                    end
                end
            end)
        end
        interactive_canvas.init()
        interactive_canvas.listener_register(self.interactive_canvas_listener)
    elseif interactive_canvas then
        jstodef.add_listener(self.interactive_canvas_listener)
        interactive_canvas.init()
        local send_text_query = interactive_canvas.send_text_query
        local debugInfo = requiref "debug.debug_info"
        interactive_canvas.send_text_query = function(text)
            if debugInfo.google.listening_mode == "CONTINUOUS_MATCH" then
                print("exit match mode")
                interactive_canvas.exit_continuous_match_mode()
                COMMON.APPLICATION.THREAD:add(function()
                    while (debugInfo.google.listening_mode == "CONTINUOUS_MATCH") do
                        print(debugInfo.google.listening_mode)
                        coroutine.yield()
                    end
                    send_text_query(text)
                end)
            else
                send_text_query(text)
            end

        end--]]
    else
        error("no interactive canvas")

    end


end

function Speech:create_listener_sber()
    local SELECTION = requiref "libs_project.selection"
    if not self.interactive_canvas_listener then
        self.interactive_canvas_listener = function(_, message_id, message)
            COMMON.i("message_id:" .. tostring(message_id) .. " data:" .. JSON.encode(message), TAG)
            if message_id == INTENTS.MESSAGES.SBER_ON_START then

            elseif message_id == INTENTS.MESSAGES.SBER_ON_DATA then
                if (message.type == "smart_app_data")  then
                    if(message.action.payload and message.action.payload.endConversation)then
                        if(interactive_canvas.exit) then
                            interactive_canvas.exit()
                        end
                        return
                    end
                    if(message.action.type == "GAME_STATE")then
                        self:set_shared(JSON.decode(message.action.payload.storage))
                    end
                    if(message.action.type == "SERVER_TECH_WORK")then
                        local SM = require "libs.sm.sm"
                        COMMON.APPLICATION.THREAD:add(function()
                            if(SM:scene_get_top()._name == SM.SCENES.SERVER_WORK_MODAL)then
                                return
                            end
                            while (SM.co) do coroutine.yield() end
                            SM:show(SM.SCENES.SERVER_WORK_MODAL)
                            while (SM.co) do coroutine.yield() end
                            if(html_utils) then html_utils.hide_bg() end
                        end)
                    end

                end
            elseif message_id == INTENTS.MESSAGES.KEY_PRESSED then
                print("KEY PRESSED")
                pprint(message)
                if (message.type == "back") then
                    interactive_canvas.send_text_query("main.close_window")
                end
                if (SELECTION.SELECTION.scene_active) then
                    if (message.type == "ok") then
                        SELECTION.SELECTION.scene_active:press()
                    elseif (message.type == "right") then
                        SELECTION.SELECTION.scene_active:focus_move_right()
                    elseif (message.type == "left") then
                        SELECTION.SELECTION.scene_active:focus_move_left()
                    elseif (message.type == "up") then
                        SELECTION.SELECTION.scene_active:focus_move_up()
                    elseif (message.type == "down") then
                        SELECTION.SELECTION.scene_active:focus_move_down()
                    end
                end

            end
        end
    end
end

function Speech:create_listener()
    local debugInfo = requiref "debug.debug_info"
    if not self.interactive_canvas_listener then
        self.interactive_canvas_listener = function(_, message_id, message)
            COMMON.EVENT_BUS:event(COMMON.EVENTS.TTS_MARK, { mark = message.markName })
            self.start_speech_time = os.clock()
            COMMON.i("message_id:" .. tostring(message_id) .. " data:" .. JSON.encode(message), TAG)
            if message_id == INTENTS.MESSAGES.IC_ON_TTS_MARK then
                if message.markName == INTENTS.TTS_MARKS.START then
                    self.start_speech_time = os.clock()
                    self.tts_playing = true
                elseif message.markName == INTENTS.TTS_MARKS.END then
                    self.tts_playing = false
                elseif message.markName == INTENTS.TTS_MARKS.ERROR then
                    self.start_speech_time = os.clock()
                    self.tts_playing = false
                    COMMON.e("tts error:" .. JSON.encode(message), TAG)
                    GA.exception("TTS:" .. JSON.encode(message))
                else

                end
            elseif message_id == INTENTS.MESSAGES.IC_ON_LISTENING_MODE_CHANGED then
                debugInfo.google.listening_mode = message.mode
            elseif message_id == INTENTS.MESSAGES.IC_ON_PHRASE_MATCHED then
                debugInfo.google.phrase_matched = message.phraseMatchResult
                COMMON.EVENT_BUS:event(COMMON.EVENTS.CONTINUOUS_MODE_MATCHED, { phraseMatchResult = message.phraseMatchResult })
            elseif message_id == INTENTS.MESSAGES.IC_ON_EXIT_CONTINUOUS_MATCH_MODE then
                COMMON.i("IC_ON_EXIT_CONTINUOUS_MATCH_MODE", TAG)
            elseif message_id == INTENTS.MESSAGES.IC_ON_UPDATE then
                --update google api from v2 to v3.
                --now it is array not object
                if (message[1]) then
                    message = message[1]
                end
                self:set_shared(message)
            end
        end
    end
end

function Speech:set_shared(message)
    self.start_shared_time = os.clock()
    self.keep_working_delay = 180
    COMMON.APPLICATION.THREAD:add(function()
        local max_delay = 0.5
        local time = 0
        local start_shared_time = self.start_shared_time
        --	while (self.start_speech_time < start_shared_time or time < max_delay) do
        --	time = time + coroutine.yield()
        --if (self.start_speech_time - self.start_shared_time < -0.1) then
        --	break
        --end
        --	end
        if not self.shared then
            local HAXE_WRAPPER = requiref "libs_project.haxe_wrapper"
            self.shared = Shared.shared.Shared.new(self.nativeApi, JSON.encode(message.storage), JSON.encode(message.contexts), true)
            requiref("debug.debug_info").sharedLoaded()
            COMMON.LOCALE:set_locale(HAXE_WRAPPER.shared_get_locale())
		else
            message.storage.clientStruct = self.prevStorage.clientStruct
            --can_restart заменяется на клиенте. Чтобы таймер работал только на клиенте
            if (message.storage.battle and self.prevStorage.battle and message.storage.battle.timerUserTurnEnd == "CAN_RESTART") then
                message.storage.battle.timerUserTurnEnd = self.prevStorage.battle.timerUserTurnEnd
            end
            self.shared = Shared.shared.Shared.new(self.nativeApi, JSON.encode(message.storage), JSON.encode(message.contexts))
        end

        if (CONSTANTS.FAKE_CANVAS) then
            self.shared:setIaps("{\r\n   \"skus\":[\r\n      {\r\n         \"title\":\"Gold Pack 1 (monstrarium-dev-ga)\",\r\n         \"description\":\"Gold Pack 1\",\r\n         \"skuId\":{\r\n            \"skuType\":\"SKU_TYPE_IN_APP\",\r\n            \"id\":\"monstrarium.gold.pack.1\",\r\n            \"packageName\":\"com.justai.monstrarium.dev\"\r\n         },\r\n         \"formattedPrice\":\"$0.99\",\r\n         \"price\":{\r\n            \"currencyCode\":\"USD\",\r\n            \"amountInMicros\":\"990000\"\r\n         }\r\n      },\r\n      {\r\n         \"title\":\"Gold Pack 2 (monstrarium-dev-ga)\",\r\n         \"description\":\"Gold Pack 2\",\r\n         \"skuId\":{\r\n            \"skuType\":\"SKU_TYPE_IN_APP\",\r\n            \"id\":\"gold.pack.2\",\r\n            \"packageName\":\"com.justai.monstrarium.dev\"\r\n         },\r\n         \"formattedPrice\":\"$2.00\",\r\n         \"price\":{\r\n            \"currencyCode\":\"USD\",\r\n            \"amountInMicros\":\"2000000\"\r\n         }\r\n      },\r\n      {\r\n         \"title\":\"Gold Pack 3 (monstrarium-dev-ga)\",\r\n         \"description\":\"Gold Pack 3\",\r\n         \"skuId\":{\r\n            \"skuType\":\"SKU_TYPE_IN_APP\",\r\n            \"id\":\"gold.pack.3\",\r\n            \"packageName\":\"com.justai.monstrarium.dev\"\r\n         },\r\n         \"formattedPrice\":\"$4.99\",\r\n         \"price\":{\r\n            \"currencyCode\":\"USD\",\r\n            \"amountInMicros\":\"4990000\"\r\n         }\r\n      }\r\n   ]\r\n}")
        end

        self.prevStorage = assert(self.shared.world.storage)
        if not GA.is_inited() then
            --	GA.init(self.shared.world.storage.version.server, self.shared.world.storage.profile.uuid)
           -- GA.event("speech", "init")
        end
        self:process_analytics(message)
        local DEBUG_INFO = requiref "debug.debug_info"
        DEBUG_INFO.conv_response(message)
        self.world:speech_process_intent(message)
        COMMON.EVENT_BUS:event(COMMON.EVENTS.STORAGE_UPDATED)
    end)
end

function Speech:process_analytics(data)
    assert(self.shared)
    assert(data)
    GA.event("intent", data.intent, data.response.modelResult.code)
    for _, v in ipairs(data.response.analyticEvents) do
        GA.event(v.category, v.event, v.label, v.value)
    end
end

function Speech:update(dt)
    if (self.keep_working_delay) then
        self.keep_working_delay =   self.keep_working_delay - dt
        if (self.keep_working_delay < 0) then
            self.keep_working_delay = 180
            interactive_canvas.send_text_query("main.keep_working")
        end
    end

end


--region logic

--endregion


return Speech()