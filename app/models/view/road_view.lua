local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

local FACTORY_URL = msg.url("main_scene:/factories#road_part_factory")
local FACTORY_CASTLE_PART = {
    ROOT = hash("root"),
    ROAD = hash("road")
}

---@class RoadPartView
local RoadPartView = COMMON.class("RoadPartView")

---@param road RoadView
function RoadPartView:initialize(road, idx)
    self.parent = road
    self.idx = idx
    self:bind_vh()
end

function RoadPartView:get_model()
    return self.parent.haxe_model[self.idx]
end

function RoadPartView:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)

    self.road_pos = self.parent.world:road_idx_to_position(self.parent.roadIdx, self.idx)
    local parts = collectionfactory.create(FACTORY_URL, self.road_pos)
    self.vh = {
        root = parts[FACTORY_CASTLE_PART.ROOT],
        road = parts[FACTORY_CASTLE_PART.ROAD],
        road_sprite = nil
    }
    ctx:remove()
end

---@class RoadView
local View = COMMON.class("RoadView")

---@param world World
function View:initialize(idx, world)
    self.roadIdx = idx
    self.world = assert(world)
    self:on_storage_changed()
    self:bind_vh()
end

function View:on_storage_changed()
    self.haxe_model = HAXE_WRAPPER.level_road_get_by_idx(self.roadIdx)
end

function View:update(dt)

end

function View:bind_vh()
    self.vh = {
        ---@param RoadPartView[]
        roads = {}
    }
    for i = 0, self.haxe_model.length - 1 do
        table.insert(self.vh.roads, RoadPartView(self, i))
    end
end

return View