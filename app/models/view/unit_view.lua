local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

local FACTORY_URL = msg.url("main_scene:/factories#unit_factory")
local FACTORY_PART = {
    ROOT = hash("/root"),
    UNIT = hash("/unit"),
    HP_TEXT = hash("/hp_text"),
    ATTACK_TEXT = hash("/attack_text")
}

---@class UnitView
local View = COMMON.class("UnitView")

---@param world World
function View:initialize(id, world)
    self.world = world
    self.unit_id = id
    self.haxe_model = HAXE_WRAPPER.level_units_get_by_id(self.unit_id) or self.haxe_model --get new model data or prev(if in was killed)
    self:bind_vh()
    self:on_storage_changed()
end


function View:on_storage_changed()
    self.haxe_model = HAXE_WRAPPER.level_units_get_by_id(self.unit_id) or self.haxe_model --get new model data or prev(if in was killed)
    label.set_text(self.vh.attack_lbl,self.haxe_model:getAttack())
    label.set_text(self.vh.hp_lbl,self.haxe_model:getHp())
end

function View:update(dt)

end

function View:road_move(road)
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local roadIdx = math.ceil(road.x / 7)
    local roadPartIdx = road.x - (roadIdx) * 7
    self.pos = self.world:road_idx_to_position(roadIdx, roadPartIdx)
    self.pos.z = -0.7
    go.set_position(self.pos, self.vh.root)
    ctx:remove()
end

function View:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    local parts = collectionfactory.create(FACTORY_URL, vmath.vector3(0, 0, 0))
    self.vh = {
        root = msg.url(assert(parts[FACTORY_PART.ROOT])),
        unit = msg.url(assert(parts[FACTORY_PART.UNIT])),
        sprite = nil,
        hp_lbl = nil,
        attack_lbl = nil
    }
    local hp_text_root = msg.url(parts[FACTORY_PART.HP_TEXT])
    local attack_text_root = msg.url(parts[FACTORY_PART.ATTACK_TEXT])
    self.vh.hp_lbl = msg.url(hp_text_root.socket, hp_text_root.path, "label")
    self.vh.attack_lbl = msg.url(attack_text_root.socket, attack_text_root.path, "label")
    self.vh.sprite = msg.url(self.vh.unit.socket, self.vh.unit.path, "sprite")
    self:road_move(self.haxe_model:getPos())

    --set sprite
    local name = "unit_" .. self.haxe_model:getType():lower() .. (self.haxe_model:getOwnerId() == 0 and "" or "_enemy")
    sprite.play_flipbook(self.vh.sprite, name)

    ctx:remove()
end

function View:hide() 
    --msg.post(self.vh.root, "disable")
    --go.delete(self.vh.root, true)
end

return View