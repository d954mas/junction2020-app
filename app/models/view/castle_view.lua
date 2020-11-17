local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"
local IceEffectView = require "models.view.effect_ice_view"
local ProjectileView = require "models.view.projectile_view"

local FACTORY_URL = msg.url("main_scene:/factories#castle_factory")
local FACTORY_CASTLE_PART = {
    ROOT = hash("/root"),
    CASTLE = hash("/castle"),
    HP_TEXT = hash("/hp_text"),
    ATTACK_TEXT = hash("/attack_text"),
    ATTACK_ICON = hash("/attack_icon"),
    HP_ICON = hash("/hp_icon"),
    CANNON = hash("/cannon")
}

local CANNON_POS_ENEMY = vmath.vector3(50, 66, 0.01)
local CANNON_POS_PLAYER = vmath.vector3(-54, 50, 0.01)

local CANNON_BALL_POS_PLAYER = vmath.vector3(38, 29, 0.01)
local CANNON_BALL_POS_ENEMY = vmath.vector3(-15, 18, 0.01)

---@class CastleView
local View = COMMON.class("CastleView")

---@param world World
function View:initialize(idx, world)
    self.world = world
    self.castleIdx = idx
    self:bind_vh()
    self:on_storage_changed()
    self:init_values()
end

function View:init_values()
    self.params = {
        hp = self.unit_model:getHp(),
        attack = self.unit_model:getAttack()
    }
    label.set_text(self.vh.hp_lbl, self.params.hp)
    label.set_text(self.vh.attack_lbl, self.params.attack)
end

function View:on_storage_changed()
    self.haxe_model = HAXE_WRAPPER.level_castle_get_by_idx(self.castleIdx)
    self.unit_model = HAXE_WRAPPER.level_units_get_by_id(self.haxe_model.unitId)
    if (self.unit_id == nil) then
        self.unit_id = self.haxe_model.unitId
        self.haxe_unit_initial = self.unit_model
    end

    if (self.unit_model) then
        --  label.set_text(self.vh.attack_lbl, self.unit_model:getAttack())
        -- label.set_text(self.vh.hp_lbl, self.unit_model:getHp())
    else
        --  label.set_text(self.vh.hp_lbl, 0)
    end
end

function View:update(dt)

end

function View:animation_ice_on()
    if (self.ice_effect) then
        return ACTIONS.Function({ fun = function()
        end })
    end
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    action:add_action(function()
        self.ice_effect = IceEffectView(self.world)
        self.ice_effect:set_scale(2)
        self.ice_effect:set_parent(self.vh.root)
        self.ice_effect:set_position(vmath.vector3(10, 0, 0.1))
        local action_ice_show = self.ice_effect:animation_show()
        while (not action_ice_show:is_finished()) do
            local dt = coroutine.yield()
            action_ice_show:update(dt)
        end
    end)
    ctx:remove()
    return action
end

function View:animation_ice_off()
    if (not self.ice_effect) then
        return ACTIONS.Function({ fun = function()
        end })
    end
    assert(self.ice_effect)
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    action:add_action(self.ice_effect:animation_hide())
    action:add_action(function()
        self.ice_effect:dispose()
        self.ice_effect = nil
    end)
    ctx:remove()
    return action
end

function View:is_player()
    return self.haxe_unit_initial:getOwnerId() == 0
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
        hp_text_root = msg.url(parts[FACTORY_CASTLE_PART.HP_TEXT]),
        attack_text_root = msg.url(parts[FACTORY_CASTLE_PART.ATTACK_TEXT]),
        hp_icon_root = msg.url(parts[FACTORY_CASTLE_PART.HP_ICON]),
        attack_icon_root = msg.url(parts[FACTORY_CASTLE_PART.ATTACK_ICON]),
        cannon = msg.url(parts[FACTORY_CASTLE_PART.CANNON]),
        cannon_sprite = nil,
        hp_lbl = nil,
        attack_lbl = nil,
    }
    self.vh.castle_sprite = msg.url(self.vh.castle.socket, self.vh.castle.path, "sprite")

    self.vh.hp_lbl = msg.url(self.vh.hp_text_root.socket, self.vh.hp_text_root.path, "label")
    self.vh.attack_lbl = msg.url(self.vh.attack_text_root.socket, self.vh.attack_text_root.path, "label")

    self.vh.cannon_sprite = msg.url(self.vh.cannon.socket, self.vh.cannon.path, "sprite")

    self.haxe_model = HAXE_WRAPPER.level_castle_get_by_idx(self.castleIdx)
    self.unit_model = HAXE_WRAPPER.level_units_get_by_id(self.haxe_model.unitId)
    sprite.play_flipbook(self.vh.castle_sprite, self.unit_model:getOwnerId() == 0 and "castle_player" or "castle_enemy")
    sprite.play_flipbook(self.vh.cannon_sprite, self.unit_model:getOwnerId() == 0 and "cannon" or "cannon_enemy")
    go.set_position(self.unit_model:getOwnerId() == 0 and CANNON_POS_PLAYER or CANNON_POS_ENEMY, self.vh.cannon)
    if (self.castleIdx == 0) then
        sprite.play_flipbook(self.vh.castle_sprite, "vilage")
        msg.post(self.vh.attack_lbl, COMMON.HASHES.MSG_DISABLE)
        msg.post(self.vh.attack_icon_root, COMMON.HASHES.MSG_DISABLE)
        msg.post(self.vh.hp_lbl, COMMON.HASHES.MSG_DISABLE)
        msg.post(self.vh.hp_icon_root, COMMON.HASHES.MSG_DISABLE)
        msg.post(self.vh.cannon, COMMON.HASHES.MSG_DISABLE)
        go.set_position(vmath.vector3(20, 50, 0), self.vh.castle)
    end
    ctx:remove()
end

function View:animation_attack(defender_id)
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)

    local projectile = ProjectileView(self.world, self:is_player() and ProjectileView.TYPES.CANNON_PLAYER or ProjectileView.TYPES.CANNON_ENEMY)
    local actions = ACTIONS.Sequence()
    local start_pos = self.castle_pos + (self:is_player() and CANNON_POS_PLAYER or CANNON_POS_ENEMY)
    start_pos = start_pos + (self:is_player() and CANNON_BALL_POS_PLAYER or CANNON_BALL_POS_ENEMY)

    local defender_view = self.world.level_model:units_view_by_id(defender_id)

    actions:add_action(projectile:animation_fly({ dispose = true, from = start_pos, to = defender_view.pos_new + vmath.vector3(0,15,0) }))




    ctx:remove()
    return actions
end

function View:animation_take_damage(damage, tag, attacker_id)
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    local action1 = ACTIONS.Sequence()
    local action2 = ACTIONS.Sequence()
    action1:add_action(ACTIONS.Tween { object = self.vh.castle_sprite, property = "flash.x", easing = TWEEN.easing.inBack, from = 0, to = 0.66, time = 0.33 })
    action1:add_action(ACTIONS.Tween { object = self.vh.castle_sprite, property = "flash.x", easing = TWEEN.easing.linear, from = 0.66, to = 0, time = 0.2 })
    action2:add_action(ACTIONS.Tween { object = self.vh.cannon_sprite, property = "flash.x", easing = TWEEN.easing.inBack, from = 0, to = 0.66, time = 0.33 })
    action2:add_action(ACTIONS.Tween { object = self.vh.cannon_sprite, property = "flash.x", easing = TWEEN.easing.linear, from = 0.66, to = 0, time = 0.2 })

    local action_parallel = ACTIONS.Parallel()
    action_parallel:add_action(action1)
    action_parallel:add_action(action2)

    action:add_action(action_parallel)
    action:add_action(function()
        self.params.hp = self.params.hp - damage
        label.set_text(self.vh.hp_lbl, math.max(0, self.params.hp))
    end)
    ctx:remove()
    return action
end

return View