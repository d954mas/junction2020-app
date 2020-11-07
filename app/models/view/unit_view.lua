local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

local FACTORY_URL = msg.url("main_scene:/factories#unit_factory")
local FACTORY_CASTLE_PART = {
    ROOT = hash("root"),
    UNIT = hash("unit")
}

---@class UnitView
local View = COMMON.class("UnitView")

---@param world World
function View:initialize(id,world)
    self.world = world
    self.unit_id = id
    self.haxe_model = HAXE_WRAPPER.level_units_get_by_id(self.unit_id) or self.haxe_model --get new model data or prev(if in was killed)
    self:bind_vh()
    self:on_storage_changed()
end

function View:on_storage_changed()
    self.haxe_model = HAXE_WRAPPER.level_units_get_by_id(self.unit_id) or self.haxe_model --get new model data or prev(if in was killed)
end

function View:update(dt)

end

function View:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local road = self.haxe_model:getPos()
    local roadIdx = math.ceil(road.x / 7)
    local roadPartIdx = road.x - (roadIdx)*7
    self.pos = self.world:road_idx_to_position(roadIdx,roadPartIdx)
    self.pos.z = -0.7
    local parts = collectionfactory.create(FACTORY_URL,self.pos)
    self.vh = {
        root = parts[FACTORY_CASTLE_PART.ROOT],
        unit = parts[FACTORY_CASTLE_PART.UNIT],
    }
    ctx:remove()
end

return View