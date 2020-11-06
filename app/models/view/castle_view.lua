local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

---@class CastleView
local View = COMMON.class("CastleView")

function View:initialize(idx)
    self.castleIdx = idx
    self:bind_vh()
    self:on_storage_changed()
end

function View:on_storage_changed()
    self.haxe_model = HAXE_WRAPPER.level_castle_get_by_idx(self.castleIdx)
end

function View:update(dt)

end

function View:bind_vh()
    self.vh = {
    }
end

return View