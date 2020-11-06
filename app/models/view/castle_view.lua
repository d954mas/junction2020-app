local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"


---@class CastleView
local View = COMMON.class("CastleView")

function View:initialize()
    self:bind_vh()
end

function View:bind_vh()
    self.vh = {


    }
end


return View