local COMMON = require "libs.common"

local UnitModel = require "models.battle.unit.unit_model"
---@class BattleEnemyModel:BattleUnitModel
local Model = COMMON.class("BattleEnemyModel",UnitModel)

---@param world World
function Model:initialize(world,haxe_unit_model,...)
	UnitModel.initialize(self,world,haxe_unit_model,false,...)
end

return Model