local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local IntentProcessor = require "libs_project.intent_processor"
local ACTIONS = require "libs.actions.actions"
local CastleView = require "models.view.castle_view"
local RoadView = require "models.view.road_view"
local UnitView = require "models.view.unit_view"
local CAMERAS = require "libs_project.cameras"
local CaravanView = require "models.view.caravan_view"

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
        units = {},
        ---@type CaravanView[]
        caravans = {}
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
    self.animation_sequence = ACTIONS.Sequence()
    self.animation_sequence.drop_empty = false;

    CAMERAS.battle_camera:set_position(vmath.vector3(640 or self.views.castles[#self.views.castles - 1].castle_pos.x, 340, 0))
end

function Level:animation_turn_start()
    self.threads = {
        die = ACTIONS.Parallel(),
        spell = ACTIONS.Parallel(),
        dieMoveToNextCastle = ACTIONS.Parallel(),
        move = ACTIONS.Parallel(),
        spawn = ACTIONS.Parallel(),
        attack = ACTIONS.Parallel(),
        take_damage = ACTIONS.Parallel(),
        castle_change = ACTIONS.Parallel(),

        caravan_spawn = ACTIONS.Parallel(),
        caravan_move = ACTIONS.Parallel(),
        caravan_load = ACTIONS.Parallel(),
        caravan_die = ACTIONS.Parallel(),
    }

    while (self.animation_sequence.current ~= nil) do
        self.animation_sequence:update(0.33)
    end
end

function Level:animation_spell_start(type)
    self.threads_mage = {
        die = ACTIONS.Parallel(),
        take_damage = ACTIONS.Parallel(),
        spell = ACTIONS.Parallel(),
    }
    self.spell_type = type

    if (self.spell_type == "ICE") then
        for _, unit in ipairs(self.views.units) do
            if (not unit:is_player()) then
                self.threads_mage.spell:add_action(unit:animation_ice_on())
            end
        end
        for _, castle in ipairs(self.views.castles) do
            if (not castle:is_player()) then
                self.threads_mage.spell:add_action(castle:animation_ice_on())
            end
        end
    end
end

function Level:caravan_spawn(id, struct)
    local view = CaravanView(id, self.world, struct)
    self.threads.spawn:add_action(view:animation_spawn())
    table.insert(self.views.caravans, view)
end


function Level:caravan_move(id, roadId)
    -- self.world.thread_sequence:add_action(function()
    local unit_view = self:caravans_view_by_id(id)
    local action = unit_view:animation_move(HAXE_WRAPPER.level_road_part_get_by_id(roadId))
    self.threads.move:add_action(action)
    --end)
end

function Level:caravan_move(id, roadId)
    -- self.world.thread_sequence:add_action(function()
    local unit_view = self:caravans_view_by_id(id)
    local action = unit_view:animation_move(HAXE_WRAPPER.level_road_part_get_by_id(roadId))
    self.threads.move:add_action(action)
    --end)
end

function Level:caravan_load(id, roadId)
    -- self.world.thread_sequence:add_action(function()
    local unit_view = self:caravans_view_by_id(id)
    local action = unit_view:caravan_load()
    self.threads.caravan_load:add_action(action)
    --end)
end

function Level:caravan_unload(id, roadId)
    -- self.world.thread_sequence:add_action(function()
    local unit_view = self:caravans_view_by_id(id)
    local action = unit_view:die()
    self.threads.caravan_die:add_action(action)
    --end)
end

function Level:animation_ice_off()
    for _, unit in ipairs(self.views.units) do
        if (not unit:is_player()) then
            self.threads.spell:add_action(unit:animation_ice_off())
        end
    end
    for _, castle in ipairs(self.views.castles) do
        if (not castle:is_player()) then
            self.threads.spell:add_action(castle:animation_ice_off())
        end
    end
end
function Level:animation_spell_end()
    self.spell_type = nil
    local threads = self.threads_mage
    self.animation_sequence:add_action(function()
        local orders = {
            threads.take_damage,
            threads.die,
        }
        while (#orders > 0 or #threads.spell.childs > 0) do
            local dt = coroutine.yield()
            local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
            threads.spell:update(dt)
            local order = orders[1]
            if (order) then
                order:update(dt)
                if (#order.childs == 0) then
                    table.remove(orders, 1)
                end
            end
            ctx:remove()
        end
    end)
    self.threads_mage = nil
    self.world.thread_sequence:add_action(function()
        while (self.animation_sequence.current ~= nil) do
            coroutine.yield()
        end
    end)
end

function Level:animation_turn_end()
    self.animation_sequence:add_action(function()
        local threads = self.threads
        local orders = {
            threads.spawn,
            threads.move,
            threads.attack,
            threads.take_damage,
            threads.die,
            threads.spell,
            threads.caravan_spawn,
            threads.caravan_move,
            threads.caravan_load,
            threads.caravan_die,

            threads.dieMoveToNextCastle,
            threads.castle_change,
        }
        while (#orders > 0) do
            local dt = coroutine.yield()
            local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
            local order = orders[1]
            order:update(dt)
            if (#order.childs == 0) then
                table.remove(orders, 1)
            end
            ctx:remove()
        end
    end)
    self.world.thread_sequence:add_action(function()
        while (self.animation_sequence.current ~= nil) do
            coroutine.yield()
        end
    end)
end

function Level:unit_died(id)
    local unit_view = self:units_view_by_id(id)
    unit_view:hide()
end

function Level:update(dt)
    for _, castle in ipairs(self.views.castles) do
        castle:update()
    end
    for _, road in ipairs(self.views.roads) do
        road:update()
    end
    for _, caravan in ipairs(self.views.caravans) do
        caravan:update()
    end
    self.animation_sequence:update(dt)
end

function Level:storage_changed()
    for _, castle in ipairs(self.views.castles) do
        castle:on_storage_changed()
    end
    for _, road in ipairs(self.views.roads) do
        road:on_storage_changed()
    end
    for _, unit in ipairs(self.views.units) do
        unit:on_storage_changed()
    end
    for _, caravan in ipairs(self.views.caravans) do
        caravan:on_storage_changed()
    end
end

function Level:units_spawn_unit(id, struct)
    --self.world.thread_sequence:add_action(function()
    local unit_view = UnitView(id, self.world, struct)
    local action = unit_view:animation_spawn();
    self.threads.spawn:add_action(action)
    table.insert(self.views.units, unit_view)
    -- end)
end

function Level:units_view_by_id(id)
    for _, view in ipairs(self.views.units) do
        if (view.unit_id == id) then
            return view
        end
    end
end


function Level:caravans_view_by_id(id)
    for _, view in ipairs(self.views.caravans) do
        if (view.unit_id == id) then
            return view
        end
    end
end

function Level:units_move_unit(id, roadId)
    -- self.world.thread_sequence:add_action(function()
    local unit_view = self:units_view_by_id(id)
    if(unit_view)then  
        local action = unit_view:animation_move(HAXE_WRAPPER.level_road_part_get_by_id(roadId))
        self.threads.move:add_action(action)
    end
    --end)
end

function Level:units_die_unit(id)
    -- self.world.thread_sequence:add_action(function()
    local unit = HAXE_WRAPPER.level_units_get_by_id(id)
    local unit_view = self:units_view_by_id(id)
    if (unit_view) then
        local action = unit_view:die()
        if (self.threads_mage) then
            self.threads_mage.die:add_action(action)
        else
            self.threads.die:add_action(action)
        end

    else
        COMMON.w("no unit view for die.Is it castle?", "LEVEL")
    end
    -- end)
end

function Level:units_attack_unit(attacker_id, defender_id)
    -- self.world.thread_sequence:add_action(function()
    local unit_view = self:units_view_by_id(attacker_id)
    if (unit_view) then
        local action = unit_view:animation_attack()
        self.threads.attack:add_action(action)
    else
        COMMON.w("no unit view for attack.Is it castle?", "LEVEL")
    end

    local unit_view_defender = self:units_view_by_id(defender_id)
    if (unit_view_defender) then
        local action = unit_view_defender:animation_take_damage()
        if (attacker_id == -10000) then
            self.threads_mage.take_damage:add_action(action)
        else
            self.threads.take_damage:add_action(action)
        end

    else
        COMMON.w("no unit view for attack.Is it castle?", "LEVEL")
    end
    -- end)
end

function Level:units_die_unit_move_to_next_castle(id)
    -- self.world.thread_sequence:add_action(function()
    local unit = HAXE_WRAPPER.level_units_get_by_id(id)
    local unit_view = self:units_view_by_id(id)
    if (unit_view) then
        local action = unit_view:die()
        self.threads.dieMoveToNextCastle:add_action(action)
    else
        COMMON.w("no unit view for die.Is it castle?", "LEVEL")
    end
    -- end)
end

function Level:castle_enemy_destroy()
    local castle_view = self.views.castles[#self.views.castles]
    self.threads.castle_change:add_action(castle_view:animate_castle_change())
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
        local bg_pos = math.floor((new_x - 640) / 2048)
        local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
        go.set_position(vmath.vector3(0 + 2048 * bg_pos, 30, -1), "/bg")
        ctx:remove()
    end)
end
--endregion


return Level