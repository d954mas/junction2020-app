local COMMON = require "libs.common"
local M = {}

function M.init()
    if(not webmonetization) then return end

    webmonetization.set_listener(function(self, event,details)
        print("event:" .. event)
        pprint(details)
        if event == webmonetization.EVENT_PENDING then
            print("The user is trying to make a first payment")
        elseif event == webmonetization.EVENT_START then
            print("The user has started paying")
        elseif event == webmonetization.EVENT_PROGRESS then
            print("The user is still paying")
        elseif event == webmonetization.EVENT_STOP then
            print("The user has stopped paying")
        end
    end)
end

function M.is_monetized()
    if(not webmonetization) then return COMMON.CONSTANTS.WEBMONETIZATION.DEFAULT_IS_ENABLE end
    return webmonetization.is_monetized()
end

return M