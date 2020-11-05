local COMMON = require "libs.common"
local JSON = require "libs_project.json"

---@class SharedNativeApi
local BaseNativeApi = COMMON.class("BaseNativeApi")

function BaseNativeApi:initialize()
end
function BaseNativeApi:saveStorage(storage)
    error("is read only")
end
function BaseNativeApi:contextSet(context, lifespan, parameters)
    error("is read only")
end
function BaseNativeApi:convAsk(string)
    error("is read only")
end
function BaseNativeApi:convAskHtmlResponse(data)
    error("is read only")
end

function BaseNativeApi:convExit()
    error("is read only")
end

---@class SharedFakeNativeApi:SharedNativeApi
local FakeNativeApi = COMMON.class("FakeNativeApi", BaseNativeApi)

---@param conv SharedFakeConversation
function FakeNativeApi:initialize(conv, send_response_f)
    self.conv = assert(conv)
    self.send_response_f = assert(send_response_f)
    self.sheduler = COMMON.RX.CooperativeScheduler.create()
end

local function saveToFile(storage)
    local file = io.open("game_storage.json", "w")
    file:write(storage)
    file:close()
end
function FakeNativeApi:saveStorage(storage)
    self.conv.user.storage = JSON.decode(storage)
    self.conv.user.storage.user = nil
    self.conv.jsons.storage = JSON.encode(JSON.decode(storage),true)
    saveToFile(self.conv.jsons.storage)
end
function FakeNativeApi:contextSet(context, lifespan, parameters)
    self.conv:set_context(context, lifespan, parameters)
end

function FakeNativeApi:flushDone()
    saveToFile(self.conv.jsons.storage)
end

function FakeNativeApi:convExit()
    saveToFile(self.conv.jsons.storage)
    sys.reboot()
end

function FakeNativeApi:convAsk(string)
    COMMON.d("convAsk:" .. tostring(string), "Conv")
    local DEBUG_INFO = requiref "debug.debug_info"
    DEBUG_INFO.conv_server_say(string)
end

function FakeNativeApi:convAskHtmlResponse(data)
    COMMON.d("convAskHtmlResponse:" .. data, "Conv")
    data = JSON.decode(data)
    --	if responce.data then responce.data = JSON.decode(responce.data) end
    --for _,listener in pairs(M.listeners)do
    --	listener(nil,INTENTS.MESSAGES.IC_ON_UPDATE,responce)
    --end
    COMMON.RX.MainScheduler:schedule(function()
        self.send_response_f(data)
    end)

end


local M = {}
M.BaseNativeApi = BaseNativeApi
M.FakeNativeApi = FakeNativeApi

return M