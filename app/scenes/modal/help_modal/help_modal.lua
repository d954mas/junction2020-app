local BaseScene = require "scenes.tracking_scene"
local COMMON = require "libs.common"
local SM = require "libs.sm.sm"
local CAMERAS = require "libs_project.cameras"

---@class HelpModal:Scene
local Scene = BaseScene:subclass("HelpModal")
function Scene:initialize()
    BaseScene.initialize(self, "HelpModal", "/help_modal#proxy", "help_modal:/scene_controller")
    self._config.modal = true
end

function Scene:on_init(go_self)
    BaseScene.on_init(self, go_self)
    COMMON.CONTEXT:register(COMMON.CONTEXT.NAMES.HELP_MODAL)
end

function Scene:on_final()
    BaseScene.on_final(self)
    COMMON.CONTEXT:unregister(COMMON.CONTEXT.NAMES.HELP_MODAL)
end
function Scene:on_input(action_id, action)
end

function Scene:on_message(message_id, message, sender)
end

return Scene