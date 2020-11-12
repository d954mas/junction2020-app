local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"

local FACTORY_URL = msg.url("main_scene:/factories#caravan_factory")
local FACTORY_PART = {
    ROOT = hash("/root"),
    UNIT = hash("/unit"),
}

---@class CaravanView
local View = COMMON.class("CaravanView")

---@param world World
function View:initialize(id, world, struct)
    self.world = world
    self.unit_id = id
    self.struct = struct
    self:bind_vh()
    self:init_values()
    self:on_storage_changed()
end

function View:init_values()

end

function View:on_storage_changed()
    if (self.haxe_model ~= nil) then
        --label.set_text(self.vh.attack_lbl, self.haxe_model:getAttack())
       -- label.set_text(self.vh.hp_lbl, self.haxe_model:getHp())
    end

end

function View:update(dt)

end

function View:road_pos_to_pos(road_pos)
    road_pos = vmath.vector3(road_pos)
    road_pos.x = road_pos.x - 20
    road_pos.y = road_pos.y + 16
    road_pos.z = -0.7
    return road_pos
end

function View:road_move(road)
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local roadIdx = math.floor(road.x / 4)
    local roadPartIdx = road.x - (roadIdx) * 4
    pprint(roadIdx)
    pprint(roadPartIdx)
    pprint("***************")
    self.pos = self:road_pos_to_pos(self.world:road_idx_to_position(roadIdx, roadPartIdx))

    go.set_position(self.pos, self.vh.root)
    ctx:remove()
end

function View:animation_spawn()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    local actionHideParallel = ACTIONS.Parallel()
    go.set(self.vh.sprite, "tint.w", 0)
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.w", from = 0, to = 1, time = 0.6 })
    action:add_action(actionHideParallel)
    ctx:remove()
    return action;
end


function View:caravan_load()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()

    action:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.w", easing = TWEEN.easing.inBack, from = 1, to = 0, time = 0.2 })
    action:add_action(function ()
       sprite.play_flipbook(self.vh.sprite,"caravan_on")
    end)
    action:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.w", easing = TWEEN.easing.inBack, from = 0, to = 1, time = 0.2 })
    ctx:remove()
    return action
end

function View:animation_move(road)
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local roadIdx = math.ceil(road.x / 4)
    local roadPartIdx = road.x - (roadIdx) * 4
    local new_pos = self:road_pos_to_pos(self.world:road_idx_to_position(roadIdx, roadPartIdx))
    local pos = self.pos
  --  self.pos = new_pos
    local action = ACTIONS.Sequence()
    local movement = ACTIONS.Tween { object = self.vh.root, property = "position", easing = TWEEN.easing.inBack, v3 = true, from = pos, to = new_pos, time = 1 }
    action:add_action(movement)
    action:add_action(function ()
        self.pos = new_pos
    end)
    ctx:remove()
    return action
end


function View:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local parts = collectionfactory.create(FACTORY_URL, vmath.vector3(0, 0, 0))
    self.vh = {
        root = msg.url(assert(parts[FACTORY_PART.ROOT])),
        unit = msg.url(assert(parts[FACTORY_PART.UNIT])),
        sprite = nil,
    }
    self.vh.sprite = msg.url(self.vh.unit.socket, self.vh.unit.path, "sprite")


    self.vh.sprite = msg.url(self.vh.unit.socket, self.vh.unit.path, "sprite")
    self:road_move(HAXE_WRAPPER.level_road_part_get_by_id(self.struct.roadPartIdx))

    ctx:remove()
end

function View:die()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    local actionHideParallel = ACTIONS.Parallel()
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.w", from = 1, to = 0, time = 0.6 })
    action:add_action(actionHideParallel)
    action:add_action(function()
        local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
        go.delete(self.vh.root, true)
        ctx:remove()
    end)
    ctx:remove()
    return action;
end

return View