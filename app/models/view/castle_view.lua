local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

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
function View:initialize(idx,world)
    self.world = world
    self.castleIdx = idx
    self:bind_vh()
    self:on_storage_changed()
end

function View:on_storage_changed()
    self.haxe_model = HAXE_WRAPPER.level_castle_get_by_idx(self.castleIdx)
    self.unit_model = HAXE_WRAPPER.level_units_get_by_id(self.haxe_model.unitId)
    label.set_text(self.vh.attack_lbl,self.unit_model:getAttack())
    label.set_text(self.vh.hp_lbl,self.unit_model:getHp())
end

function View:update(dt)

end

function View:bind_vh()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE)
    self.castle_pos = self.world:castle_idx_to_position(self.castleIdx)
    local parts = collectionfactory.create(FACTORY_URL,self.castle_pos)
    self.vh = {
        root = assert(parts[FACTORY_CASTLE_PART.ROOT]),
        castle = assert(parts[FACTORY_CASTLE_PART.CASTLE]),
        castle_sprite = nil,
        hp_lbl = nil,
        attack_lbl = nil,
    }
    local hp_text_root = msg.url(parts[FACTORY_CASTLE_PART.HP_TEXT])
    local attack_text_root = msg.url(parts[FACTORY_CASTLE_PART.ATTACK_TEXT])
    self.vh.hp_lbl = msg.url(hp_text_root.socket, hp_text_root.path, "label")
    self.vh.attack_lbl = msg.url(attack_text_root.socket, attack_text_root.path, "label")
    ctx:remove()
end

return View