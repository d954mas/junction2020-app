local BaseScene = require "scenes.tracking_scene"
local COMMON = require "libs.common"
local SM = require "libs.sm.sm"

---@class MainScene:Scene
local Scene = BaseScene:subclass("MainScene")
function Scene:initialize()
	BaseScene.initialize(self, "MainScene", "/main_scene#proxy", "main_scene:/scene_controller")
end

function Scene:on_show()
	BaseScene.on_show(self)
end

function Scene:on_hide()
	BaseScene.on_hide(self)
end

function Scene:on_update(dt)
	BaseScene.on_update(self, dt)
end

function Scene:on_input(action_id, action)
end

function Scene:on_message(message_id, message, sender)
end

return Scene