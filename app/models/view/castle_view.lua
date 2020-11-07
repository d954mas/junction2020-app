local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"

local FACTORY_URL = msg.url("main_scene:/factories#castle_factory")
local FACTORY_CASTLE_PART = {
    ROOT = hash("/root"),
    CASTLE = hash("/castle"),
    HP_TEXT = hash("/hp_text"),
    ATTACK_TEXT = hash("/attack_text")
}

---@class CastleView
local View = COMMON.class("CastleView")

---@param world World
function View:initialize(idx, world)
    self.world = world
    self.castleIdx = idx
    self:bind_vh()
    self:on_storage_changed()
end

function View:on_storage_changed()
    self.haxe_model = HAXE_WRAPPER.level_castle_get_by_idx(self.castleIdx)
    self.unit_model = HAXE_WRAPPER.level_units_get_by_id(self.haxe_model.unitId)
    if (self.unit_model) then
        label.set_text(self.vh.attack_lbl, self.unit_model:getAttack())
        label.set_text(self.vh.hp_lbl, self.unit_model:getHp())
    else
        label.set_text(self.vh.hp_lbl, 0)
    end
end

function View:update(dt)

end

function View:animation_ice_on()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Parallel()
    action:add_action(ACTIONS.Tween { object = self.vh.castle_sprite, property = "tint.x", easing = TWEEN.easing.inExpo,  from = 1, to = 0, time = 0.33 })
    action:add_action(ACTIONS.Tween { object = self.vh.castle_sprite, property = "tint.y", easing = TWEEN.easing.inExpo,  from = 1, to = 0, time = 0.33 })
    ctx:remove()
    return action
end

function View:animation_ice_off()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Parallel()
    action:add_action(ACTIONS.Tween { object = self.vh.castle_sprite, property = "tint.x", easing = TWEEN.easing.inExpo, from = 0, to = 1, time = 0.33 })
    action:add_action(ACTIONS.Tween { object = self.vh.castle_sprite, property = "tint.y", easing = TWEEN.easing.inExpo, from = 0, to = 1, time = 0.33 })
    ctx:remove()
    return action
end

function View:is_player()
    self.haxe_model = HAXE_WRAPPER.level_castle_get_by_idx(self.castleIdx)
    self.unit_model = HAXE_WRAPPER.level_units_get_by_id(self.haxe_model.unitId)
    return self.unit_model:getOwnerId() == 0
end

function View:animate_castle_change()
    local actionSequence = ACTIONS.Sequence()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    actionSequence:add_action(ACTIONS.Tween { object = self.vh.castle_sprite, property = "tint.w", from = 1, to = 0, time = 0.4 })
    actionSequence:add_action(function()
        sprite.play_flipbook(self.vh.castle_sprite, "castle_player")
    end)
    actionSequence:add_action(ACTIONS.Tween { object = self.vh.castle_sprite, property = "tint.w", from = 0, to = 1, time = 0.4 })
    ctx:remove()
    return actionSequence;
end

function View:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    self.castle_pos = self.world:castle_idx_to_position(self.castleIdx)
    local parts = collectionfactory.create(FACTORY_URL, self.castle_pos)
    self.vh = {
        root = msg.url(assert(parts[FACTORY_CASTLE_PART.ROOT])),
        castle = msg.url(assert(parts[FACTORY_CASTLE_PART.CASTLE])),
        castle_sprite = nil,
        hp_lbl = nil,
        attack_lbl = nil,
    }
    self.vh.castle_sprite = msg.url(self.vh.castle.socket, self.vh.castle.path, "sprite")

    local hp_text_root = msg.url(parts[FACTORY_CASTLE_PART.HP_TEXT])
    local attack_text_root = msg.url(parts[FACTORY_CASTLE_PART.ATTACK_TEXT])
    self.vh.hp_lbl = msg.url(hp_text_root.socket, hp_text_root.path, "label")
    self.vh.attack_lbl = msg.url(attack_text_root.socket, attack_text_root.path, "label")

    self.haxe_model = HAXE_WRAPPER.level_castle_get_by_idx(self.castleIdx)
    self.unit_model = HAXE_WRAPPER.level_units_get_by_id(self.haxe_model.unitId)
    sprite.play_flipbook(self.vh.castle_sprite, self.unit_model:getOwnerId() == 0 and "castle_player" or "castle_enemy")

    ctx:remove()
end

return View