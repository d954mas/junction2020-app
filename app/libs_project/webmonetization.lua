local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local M = {}

function M.init()
    if(not webmonetization) then return end

    webmonetization.set_listener(function(self, event,details)
        print("event:" .. event)
        pprint(details)
        if event == webmonetization.EVENT_PENDING then
        elseif event == webmonetization.EVENT_START then
        elseif event == webmonetization.EVENT_PROGRESS then
        elseif event == webmonetization.EVENT_STOP then
        end
    end)
end

function M.is_monetized()
    if(not webmonetization) then return COMMON.CONSTANTS.WEBMONETIZATION.DEFAULT_IS_ENABLE end
    return webmonetization.is_monetized()
end

return M