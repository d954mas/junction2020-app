local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

local FACTORY_URL = msg.url("main_scene:/factories#castle_factory")
local FACTORY_CASTLE_PART = {
    ROOT = hash("root"),
    CASTLE = hash("castle")
}

---@class CastleView
local View = COMMON.class("CastleView")

---@param world World
function View:initialize(idx,world)
    self.world = world
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
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    self.castle_pos = self.world:castle_idx_to_position(self.castleIdx)
    local parts = collectionfactory.create(FACTORY_URL,self.castle_pos)
    self.vh = {
        root = parts[FACTORY_CASTLE_PART.ROOT],
        castle = parts[FACTORY_CASTLE_PART.CASTLE],
        castle_sprite = nil
    }
    ctx:remove()
end

return View