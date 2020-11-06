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
function RoadPartView:initialize(road,idx)
    self.parent = road
    self.idx = idx
    self:bind_vh()
end

function RoadPartView:get_model()
    return self.parent.haxe_model[self.idx]
end

function RoadPartView:bind_vh()
    --Координаты примерный. Надо будет поправить под конечный ui
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local model = self:get_model()
    local y = 270
    local x = COMMON.CONSTANTS.CONFIG.CASTLE_DMOVE
    local half_castle_size = 70
    local road_size = 82
    x = x + 40 --start from castle center
    x = x + half_castle_size
    x = x + model.x * road_size

    local five_roads_gap =half_castle_size*2
    x = x + five_roads_gap * math.floor(model.x /5)

    self.road_pos = vmath.vector3(x,y,-0.9)
    local parts = collectionfactory.create(FACTORY_URL,self.road_pos)
    self.vh = {
        root = parts[FACTORY_CASTLE_PART.ROOT],
        road = parts[FACTORY_CASTLE_PART.ROAD],
        road_sprite = nil
    }
    ctx:remove()
end

---@class RoadView
local View = COMMON.class("RoadView")

function View:initialize(idx)
    self.roadIdx = idx
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
        table.insert(self.vh.roads, RoadPartView(self,i))
    end
end

return View