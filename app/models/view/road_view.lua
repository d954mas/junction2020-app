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

function View:initialize()
    self:bind_vh()
end

function View:bind_vh()
    self.vh = {
        ---@type RoadPartView[]
        roads = {}
    }
end

return View