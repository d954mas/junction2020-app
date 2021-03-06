local BaseScene = require "scenes.tracking_scene"
local COMMON = require "libs.common"
local SM = require "libs.sm.sm"
local CAMERAS = require "libs_project.cameras"

---@class TestSpineScene:Scene
local Scene = BaseScene:subclass("TestSpineScene")
function Scene:initialize()
	BaseScene.initialize(self, "TestSpineScene", "/test_spine#proxy", "test_spine:/scene_controller")
end

function Scene:on_show()
	BaseScene.on_show(self)
	CAMERAS:set_current(CAMERAS.battle_camera)
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