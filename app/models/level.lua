local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local IntentProcessor = require "libs_project.intent_processor"
local ACTIONS = require "libs.actions.actions"
local CastleView = require "models.view.castle_view"
local RoadView = require "models.view.road_view"
local UnitView = require "models.view.unit_view"
local CAMERAS = require "libs_project.cameras"

---@class Level
local Level = COMMON.class("Level")

---@param world World
function Level:initialize(world)
    self.world = world
    self.views = {
        ---@type CastleView[]
        castles = {},
        ---@type RoadView[]
        roads = {},
        ---@type UnitView[]
        units = {}
    }
    --iterate all and create all views
    local castles = HAXE_WRAPPER.level_castles_get_array()
    for i = 0, castles.length - 1 do
        table.insert(self.views.castles, CastleView(i, self.world))
    end
    local roads = HAXE_WRAPPER.level_roads_get_array()
    for i = 0, roads.length - 1 do
        table.insert(self.views.roads, RoadView(i, self.world))
    end

    CAMERAS.battle_camera:set_position(vmath.vector3(640 or self.views.castles[#self.views.castles - 1].castle_pos.x, 340, 0))
end

function Level:update(dt)
    for _, castle in ipairs(self.views.castles) do
        castle:update()
    end
    for _, road in ipairs(self.views.roads) do
        road:update()
    end
end

function Level:storage_changed()
    for _, castle in ipairs(self.views.castles) do
        castle:on_storage_changed()
    end
    for _, road in ipairs(self.views.roads) do
        road:on_storage_changed()
    end
end

function Level:units_spawn_unit(id)
    self.world.thread_sequence:add_action(function()
        local unit_view = UnitView(id, self.world)
        table.insert(self.views, unit_view)
    end)
end

function Level:move_to_next()
    self.world.thread_sequence:add_action(function()
        local next_castle_id = #self.views.castles
        table.insert(self.views.castles, CastleView(next_castle_id, self.world))
        table.insert(self.views.roads, RoadView(next_castle_id - 1, self.world))
        local max_time = 1
        local time = 1
        local current_y = CAMERAS.battle_camera.wpos.y
        local current_x = CAMERAS.battle_camera.wpos.x
        local new_x = self.views.castles[#self.views.castles - 1].castle_pos.x
        while (time > 0) do
            local x = COMMON.LUME.lerp(current_x, new_x, 1 - time / max_time)
            CAMERAS.battle_camera:set_position(vmath.vector3(x, current_y, 0))
            local dt = coroutine.yield()
            time = time - dt
        end
        CAMERAS.battle_camera:set_position(vmath.vector3(new_x, current_y, 0))
    end)
end
--endregion


return Level