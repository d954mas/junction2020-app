local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

---@class RoadPartView
local RoadPartView = COMMON.class("RoadPartView")

function RoadPartView:initialize()
    self:bind_vh()
end

function RoadPartView:bind_vh()
    self.vh = {}
end

---@class RoadView
local View = COMMON.class("RoadView")

function View:initialize(idx)
    self.roadIdx = idx
    self:bind_vh()
    self:on_storage_changed()
end

function View:on_storage_changed()
    self.haxe_model = HAXE_WRAPPER.level_road_get_by_idx(self.roadIdx)
end

function View:update(dt)

end


function View:bind_vh()
    self.vh = {
    }
end

return View