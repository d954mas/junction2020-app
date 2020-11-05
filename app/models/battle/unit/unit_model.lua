local COMMON = require "libs.common"

---@class BattleUnitModel
local Model = COMMON.class("BattleUnitModel")

---@param world World
function Model:initialize(world, haxe_unit_model, is_hero)
    self.world = assert(world)
    self.hero = is_hero
    self.haxe_unit_model = assert(haxe_unit_model)
    self.attributes = {
        hp_max = haxe_unit_model.storage.hpMax,
        hp_current = haxe_unit_model.storage.hp
    }
end

function Model:is_hero()
    return self.hero
end

return Model