local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local IntentProcessor = require "libs_project.intent_processor"
local ACTIONS = require "libs.actions.actions"


---@class level
local Level = COMMON.class("Level")

---@param world World
function Level:initialize(world)
    self.world = world
    self.views = {

    }
end

function Level:update(dt)

end

function Level:storage_changed()
end
--endregion


return Level