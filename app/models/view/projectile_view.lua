local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"
local Curve = require "libs.curve"

local FACTORY_URL = msg.url("main_scene:/factories#effect_fireball_factory")

local FACTORY_PART = {
    ROOT = hash("/root"),
    SPRITE = hash("/sprite"),
    SPRITE_ORIGIN = hash("/sprite_origin"),
}

---@class ProjectileView
local View = COMMON.class("ProjectileView")

View.TYPES = {
    CANNON_PLAYER = "CANNON_PLAYER",
    CANNON_ENEMY = "CANNON_ENEMY",
    ARROW_PLAYER = "ARROW_PLAYER",
    ARROW_ENEMY = "ARROW_ENEMY",
    MAGE_PLAYER = "MAGE_PLAYER",
    MAGE_ENEMY = "MAGE_ENEMY",
}

local TYPE_CONFIGS = {
    [View.TYPES.CANNON_PLAYER] = { factory = msg.url("main_scene:/factories#projectile_cannon_player_factory"), scale = 1, y_top = 20 },
    [View.TYPES.CANNON_ENEMY] = { factory = msg.url("main_scene:/factories#projectile_cannon_enemy_factory"), scale = 1, y_top = 20 },
    [View.TYPES.ARROW_PLAYER] = { factory = msg.url("main_scene:/factories#projectile_arrow_player_factory"), scale = 1, y_top = 90 },
    [View.TYPES.ARROW_ENEMY] = { factory = msg.url("main_scene:/factories#projectile_arrow_enemy_factory"), scale = 1, y_top = 90 },
    [View.TYPES.MAGE_PLAYER] = { factory = msg.url("main_scene:/factories#projectile_mage_player_factory"), scale = 1, y_top = 50 },
    [View.TYPES.MAGE_ENEMY] = { factory = msg.url("main_scene:/factories#projectile_mage_enemy_factory"), scale = 1, y_top = 50 }
}

---@param world World
function View:initialize(world, type)
    self.config = assert(TYPE_CONFIGS[type], "unknown type:" .. tostring(type))
    self.world = assert(world)
    self:bind_vh()
    self:init_view()
end

function View:init_view()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    go.set(self.vh.sprite_origin_sprite, "tint.w", 0)
    self:set_scale(self.config.scale)
    ctx:remove()
end

function View:set_scale(scale)
    go.set_scale(scale, self.vh.root)
end

function View:set_position(pos)
    go.set_position(pos, self.vh.root)
end

function View:update(dt)

end

function View:animation_fly(config)
    checks("?", { from = "userdata", to = "userdata", dispose = "nil|boolean", y_top = "nil|number" })
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local action = ACTIONS.Sequence()
    action:add_action(function()
        self:set_position(config.from)
        -- go.set(self.vh.sprite_origin_sprite, "tint.w", 1)
    end)
    config.y_top = config.y_top or self.config.y_top
    config.from.z = 0.2
    config.to.z = config.from.z
    local middle =config.from +  (config.to-config.from)/2
    middle.y = middle.y + config.y_top
    local curve = Curve({ points = { config.from, middle, config.to } })
    local movement = ACTIONS.Function { fun = function()
        local movement_a = 0
        local len = 0
        local end_len = curve.len
        --local speed = config.speed
        --  if (not speed) then
        --     local time = assert(config.speed, "need speed or time")
        local speed = curve.len / 0.5
        --  end
        while (len < end_len) do
            local dt = coroutine.yield()
            len = len + dt * speed
            len = math.min(len, end_len)
            movement_a = len / end_len
            local pos = curve:point_interpolated_get(len / end_len)
            go.set_position(pos, self.vh.root)
        end
    end }
    action:add_action(ACTIONS.Tween { object = self.vh.sprite_origin_sprite, property = "tint.w", easing = TWEEN.easing.linear, from = 0, to = 1, time = 0.1 })
    --action:add_action(ACTIONS.Tween { object = self.vh.root, property = "position", v3 = true, easing = TWEEN.easing.linear, from = config.from, to = config.to, time = 5.7 })
    action:add_action(movement)
    action:add_action(ACTIONS.Tween { object = self.vh.sprite_origin_sprite, property = "tint.w", easing = TWEEN.easing.linear, from = 1, to = 0, time = 0.15 })
    if (config.dispose) then
        action:add_action(function()
            self:dispose()
        end)
    end
    ctx:remove()
    return action
end

function View:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local parts = collectionfactory.create(self.config.factory)
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
    self.vh = nil
end

return View