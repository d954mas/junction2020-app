local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"

local FACTORY_URL = msg.url("main_scene:/factories#unit_factory")
local FACTORY_PART = {
    ROOT = hash("/root"),
    UNIT = hash("/unit"),
    HP_ICON = hash("/hp_icon"),
    HP_TEXT = hash("/hp_text"),
    ATTACK_TEXT = hash("/attack_text"),
    ATTACK_ICON = hash("/attack_icon")
}

---@class UnitView
local View = COMMON.class("UnitView")

---@param world World
function View:initialize(id, world, struct)
    self.world = world
    self.unit_id = id
    self.struct = struct
    self.haxe_unit_initial = HAXE_WRAPPER.level_units_create_battle_unit_model(self.struct)
    self.haxe_model = HAXE_WRAPPER.level_units_get_by_id(self.unit_id) or self.haxe_model --get new model data or prev(if in was killed)
    self:bind_vh()
    self:init_values()
    self:on_storage_changed()
end

function View:init_values()
    self.params = {
        hp = self.haxe_unit_initial:getAttack(),
        attack = self.haxe_unit_initial:getHp()
    }
    label.set_text(self.vh.attack_lbl, self.params.hp)
    label.set_text(self.vh.hp_lbl, self.params.attack)
end

function View:on_storage_changed()
    self.haxe_model = HAXE_WRAPPER.level_units_get_by_id(self.unit_id) or self.haxe_model --get new model data or prev(if in was killed)
    if (self.haxe_model ~= nil) then
        --  label.set_text(self.vh.attack_lbl, self.haxe_model:getAttack())
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
    local roadIdx = math.ceil(road.x / 7)
    local roadPartIdx = road.x - (roadIdx) * 7
    self.pos = self:road_pos_to_pos(self.world:road_idx_to_position(roadIdx, roadPartIdx))

    go.set_position(self.pos, self.vh.root)
    ctx:remove()
end

function View:animation_spawn()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    local actionHideParallel = ACTIONS.Parallel()
    go.set(self.vh.sprite, "tint.w", 0)
    go.set(self.vh.attack_icon, "tint.w", 0)
    go.set(self.vh.hp_icon, "tint.w", 0)
    go.set(self.vh.hp_lbl, "tint.w", 0)
    go.set(self.vh.attack_lbl, "tint.w", 0)
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.w", from = 0, to = 1, time = 0.6 })
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.attack_icon, property = "tint.w", from = 0, to = 1, time = 0.6 })
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.hp_icon, property = "tint.w", from = 0, to = 1, time = 0.6 })
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.hp_lbl, property = "tint.w", from = 0, to = 1, time = 0.6 })
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.attack_lbl, property = "tint.w", from = 0, to = 1, time = 0.6 })
    action:add_action(actionHideParallel)
    ctx:remove()
    return action;
end

function View:animation_move(road)
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local roadIdx = math.ceil(road.x / 7)
    local roadPartIdx = road.x - (roadIdx) * 7
    local new_pos = self:road_pos_to_pos(self.world:road_idx_to_position(roadIdx, roadPartIdx))
    local pos = self.pos
    --  self.pos = new_pos
    local action = ACTIONS.Sequence()
    local movement = ACTIONS.Tween { object = self.vh.root, property = "position", easing = TWEEN.easing.inBack, v3 = true, from = pos, to = new_pos, time = 1 }
    action:add_action(movement)
    action:add_action(function()
        self.pos = new_pos
    end)
    ctx:remove()
    return action
end

function View:animation_attack()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local new_pos = vmath.vector3(self.pos)
    new_pos.x = new_pos.x + (self.haxe_unit_initial:getOwnerId() == 0 and 15 or -15)
    local action = ACTIONS.Sequence()
    action:add_action(ACTIONS.Tween { object = self.vh.root, property = "position", easing = TWEEN.easing.inBack, v3 = true, from = self.pos, to = new_pos, time = 0.2 })
    action:add_action(ACTIONS.Tween { object = self.vh.root, property = "position", easing = TWEEN.easing.linear, v3 = true, from = new_pos, to = self.pos, time = 0.1 })
    ctx:remove()
    return action
end

function View:is_player()
    return self.haxe_unit_initial:getOwnerId() == 0
end

function View:animation_ice_on()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Parallel()
    action:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.x", easing = TWEEN.easing.inExpo, from = 1, to = 0, time = 0.33 })
    action:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.y", easing = TWEEN.easing.inExpo, from = 1, to = 0, time = 0.33 })
    ctx:remove()
    return action
end

function View:animation_ice_off()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Parallel()
    action:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.x", easing = TWEEN.easing.inExpo, from = 0, to = 1, time = 0.33 })
    action:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.y", easing = TWEEN.easing.inExpo, from = 0, to = 1, time = 0.33 })
    ctx:remove()
    return action
end

function View:animation_take_damage(damage, tag, attacker_id)
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    action:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "flash.x", easing = TWEEN.easing.inBack, from = 0, to = 0.66, time = 0.33 })
    action:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "flash.x", easing = TWEEN.easing.linear, from = 0.66, to = 0, time = 0.2 })
    action:add_action(function()
        self.params.hp = self.params.hp - damage
        label.set_text(self.vh.hp_lbl, math.max(0,self.params.hp))
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
        hp_lbl = nil,
        hp_icon = nil,
        attack_icon = nil,
        attack_lbl = nil,
    }
    self.vh.sprite = msg.url(self.vh.unit.socket, self.vh.unit.path, "sprite")

    local hp_text_root = msg.url(parts[FACTORY_PART.HP_TEXT])
    local attack_text_root = msg.url(parts[FACTORY_PART.ATTACK_TEXT])
    self.vh.hp_lbl = msg.url(hp_text_root.socket, hp_text_root.path, "label")
    self.vh.attack_lbl = msg.url(attack_text_root.socket, attack_text_root.path, "label")

    local hp_icon_root = msg.url(parts[FACTORY_PART.HP_ICON])
    local attack_icon_root = msg.url(parts[FACTORY_PART.ATTACK_ICON])
    self.vh.hp_icon = msg.url(hp_icon_root.socket, hp_icon_root.path, "sprite")
    self.vh.attack_icon = msg.url(attack_icon_root.socket, attack_icon_root.path, "sprite")

    self.vh.sprite = msg.url(self.vh.unit.socket, self.vh.unit.path, "sprite")
    self:road_move(self.haxe_unit_initial:getPos())

    --set sprite
    local name = "unit_" .. self.haxe_unit_initial:getType():lower() .. (self.haxe_unit_initial:getOwnerId() == 0 and "" or "_enemy")
    sprite.play_flipbook(self.vh.sprite, name)

    ctx:remove()
end

function View:die()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    local actionHideParallel = ACTIONS.Parallel()
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.sprite, property = "tint.w", from = 1, to = 0, time = 0.6 })
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.attack_icon, property = "tint.w", from = 1, to = 0, time = 0.6 })
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.hp_icon, property = "tint.w", from = 1, to = 0, time = 0.6 })
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.hp_lbl, property = "tint.w", from = 1, to = 0, time = 0.6 })
    actionHideParallel:add_action(ACTIONS.Tween { object = self.vh.attack_lbl, property = "tint.w", from = 1, to = 0, time = 0.6 })
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