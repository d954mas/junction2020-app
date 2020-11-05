local BaseScene = require "libs.sm.scene"
local COMMON = require "libs.common"
local RENDERCAM = require "rendercam.rendercam"
local SM = require "libs.sm.sm"
local GA = require "libs_project.google_analytics"

---@class TrackingScene:Scene
local Scene = BaseScene:subclass("TrackingScene")
function Scene:initialize(name, url, proxy)
    BaseScene.initialize(self, name, url, proxy)
end

function Scene:on_show()
    BaseScene.on_show(self)
    self.time = os.time()
   -- GA.event("scene", "show", self._name)
   -- GA.screenview(self._name)
    COMMON.input_acquire()
end

function Scene:on_hide()
    BaseScene.on_hide(self)
    self:send_timing()
    COMMON.input_release()
end

function Scene:send_timing()
    if (self.time) then
        local timing = os.time() - self.time
        self.time = nil
     --   GA.event("scene", "hide", self._name)
     --   GA.timing("scene", self._name, timing)
    --    GA.flush()
    end
end

return Scene