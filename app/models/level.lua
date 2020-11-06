local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local IntentProcessor = require "libs_project.intent_processor"
local ACTIONS = require "libs.actions.actions"
local CastleView = require "models.view.castle_view"
local RoadView = require "models.view.road_view"
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
        roads = {}
    }
    --iterate all and create all views
    local castles = HAXE_WRAPPER.level_castles_get_array()
    for i = 0, castles.length - 1 do
        table.insert(castles, CastleView(i))
    end
    local roads = HAXE_WRAPPER.level_roads_get_array()
    for i = 0, roads.length - 1 do
        table.insert(roads, RoadView(i))
    end
    CAMERAS.battle_camera:set_position(vmath.vector3(1280 / 2 * (castles.length - 2), 340, 0))
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
--endregion


return Level