local BaseScene = require "scenes.tracking_scene"
local COMMON = require "libs.common"
local SM = require "libs.sm.sm"
local CAMERAS = require "libs_project.cameras"

---@class MainScene:Scene
local Scene = BaseScene:subclass("MainScene")
function Scene:initialize()
    BaseScene.initialize(self, "MainScene", "/main_scene#proxy", "main_scene:/scene_controller")
end

function Scene:on_init(go_self)
    BaseScene.on_init(self, go_self)
    COMMON.CONTEXT:register(COMMON.CONTEXT.NAMES.MAIN_SCENE)
end

function Scene:on_show()

    BaseScene.on_show(self)
    CAMERAS:set_current(CAMERAS.battle_camera)
    sprite.set_constant("main_scene:/game_mock#sprite", "tint", vmath.vector4(1, 1, 1, 0.33))
end

function Scene:on_hide()
    BaseScene.on_hide(self)
end

function Scene:on_update(dt)
    BaseScene.on_update(self, dt)
end

function Scene:on_update(dt)
    BaseScene.on_update(self, dt)
end

function Scene:on_final()
    BaseScene.on_final(self)
    COMMON.CONTEXT:unregister(COMMON.CONTEXT.NAMES.MAIN_SCENE)
end
function Scene:on_input(action_id, action)
end

function Scene:on_message(message_id, message, sender)
end

return Scene