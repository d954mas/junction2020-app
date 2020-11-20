local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"

local FACTORY_URL = msg.url("main_scene:/factories#effect_change_mana")
local FACTORY_PART = {
    ROOT = hash("/root"),
    LABEL = hash("/label"),
    SPRITE = hash("/sprite"),
}

---@class ChangeManaEffectView
local View = COMMON.class("ChangeManaEffectView")

---@param world World
function View:initialize(world)
    self.world = world
    self:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    go.set(self.vh.label_label, "tint.w", 0)
    ctx:remove()
end

function View:set_position(pos)
    go.set_position(pos, self.vh.root)
end

function View:set_scale(scale)
    go.set_scale(scale, self.vh.root)
end

function View:update(dt)

end

function View:animation_show(config)
    checks("?", { from = "userdata", value = "number" })
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    label.set_text(self.vh.label_label,(config.value> 0 and "+" or "") .. config.value)
    local action = ACTIONS.Parallel()
    local sequenceAction = ACTIONS.Sequence()
    action:add_action(function()
        local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
        go.set(self.vh.label_label, "tint.w", 0)
        ctx:remove()
    end)
    config.from.x = config.from.x
    local to = config.from +  vmath.vector3(0, 200,0)

  --  local delay = math.random()* 0.25
 --   sequenceAction:add_action(ACTIONS.Wait{time = delay})
    sequenceAction:add_action(action)

    action:add_action(ACTIONS.Tween { object = self.vh.label_label, property = "tint.w", easing = TWEEN.easing.inExpo, from = 0, to = 1, time = 0.33 })
    action:add_action(ACTIONS.Tween { object = self.vh.sprite_sprite, property = "tint.w", easing = TWEEN.easing.inExpo, from = 0, to = 1, time = 0.33 })
    action:add_action(ACTIONS.Tween { object = self.vh.root, property = "position", v3 = true, easing = TWEEN.easing.linear, from = config.from, to = to, time = 1.4 })
    action:add_action(ACTIONS.Tween { delay = 1, object = self.vh.label_label, property = "tint.w", easing = TWEEN.easing.inExpo, from = 1, to = 0, time = 0.33 })
    action:add_action(ACTIONS.Tween { delay = 1, object = self.vh.sprite_sprite, property = "tint.w", easing = TWEEN.easing.inExpo, from = 1, to = 0, time = 0.33 })
    action:add_action(ACTIONS.Function { fun = function()
        COMMON.COROUTINES.coroutine_wait(2)
        self:dispose()
    end })
    ctx:remove()
    return sequenceAction
end

function View:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local parts = collectionfactory.create(FACTORY_URL)
    self.vh = {
        root = msg.url(assert(parts[FACTORY_PART.ROOT])),
        label = msg.url(assert(parts[FACTORY_PART.LABEL])),
        label_label = nil,
        sprite = msg.url(assert(parts[FACTORY_PART.SPRITE])),
        sprite_sprite = nil
    }
    self.vh.label_label = msg.url(self.vh.label.socket, self.vh.label.path, "label")
    self.vh.sprite_sprite = msg.url(self.vh.sprite.socket, self.vh.sprite.path, "sprite")
    ctx:remove()
end

function View:dispose()
    go.delete(self.vh.root, true)
    self.vh = nil
end

return View