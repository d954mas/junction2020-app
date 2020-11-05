local COMMON = require "libs.common"

local UnitModel = require "models.battle.unit.unit_model"
---@class BattleHeroModel:BattleUnitModel
local Model = COMMON.class("BattleHeroModel",UnitModel)

---@param world World
function Model:initialize(world,haxe_unit_model,...)
	UnitModel.initialize(self,world,haxe_unit_model,true,...)
end

return Model