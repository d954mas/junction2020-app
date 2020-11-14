local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"

local FACTORY_URL = msg.url("main_scene:/factories#effect_fireball_factory")
local FACTORY_PART = {
    ROOT = hash("/root"),
    SPRITE = hash("/sprite"),
    SPRITE_ORIGIN = hash("/sprite_origin"),
}

---@class FireballEffectView
local View = COMMON.class("FireballEffectView")

---@param world World
function View:initialize(world)
    self.world = world
    self:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    go.set(self.vh.sprite_origin_sprite, "tint.w", 0)
    ctx:remove()
end

function View:set_position(pos)
    go.set_position(pos, self.vh.root)
end

function View:set_parent(parent)
    go.set_parent(self.vh.root, parent)
end

function View:set_scale(scale)
    go.set_scale(scale, self.vh.root)
end

function View:update(dt)

end

function View:animation_fly(config)
    checks("?", { from = "userdata", to = "userdata" })
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    action:add_action(function()
        self:set_position(config.from)
    end)
    action:add_action(ACTIONS.Tween { object = self.vh.sprite_origin_sprite, property = "tint.w", easing = TWEEN.easing.linear, from = 0, to = 1, time = 0.15 })
    action:add_action(ACTIONS.Tween { object = self.vh.root, property = "position", v3 = true, easing = TWEEN.easing.linear, from = config.from, to = config.to, time = 0.7 })
    action:add_action(ACTIONS.Tween { object = self.vh.sprite_origin_sprite, property = "tint.w", easing = TWEEN.easing.linear, from = 1, to = 0, time = 0.15 })
    ctx:remove()
    return action
end

function View:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local parts = collectionfactory.create(FACTORY_URL)
    self.vh = {
        root = msg.url(assert(parts[FACTORY_PART.ROOT])),
        sprite = msg.url(assert(parts[FACTORY_PART.SPRITE])),
        sprite_origin = msg.url(assert(parts[FACTORY_PART.SPRITE_ORIGIN])),
        sprite_origin_sprite = nil,
    }
    self.vh.sprite_origin_sprite = msg.url(self.vh.sprite_origin.socket, self.vh.sprite_origin.path, "sprite")
    ctx:remove()
end

function View:dispose()
    go.delete(self.vh.root, true)
end

return View