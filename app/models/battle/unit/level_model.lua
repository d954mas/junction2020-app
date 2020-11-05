local COMMON = require "libs.common"
local HeroModel = require "models.battle.unit.hero_model"
local EnemyModel = require "models.battle.unit.enemy_model"


---@class BattleLevelModel
local Model = COMMON.class("BattleLevelModel")

---@param world World
function Model:initialize(world)
	self.world = world
	self.haxe_level_model = COMMON.meta_getter(function () return self.world.speech.shared.world.battleModel.levelModel end)
	self.hero_model = HeroModel(self.world, COMMON.meta_getter(function () return self.haxe_level_model.heroModel end))
	self.enemy_model = EnemyModel(self.world, COMMON.meta_getter(function () return self.haxe_level_model.enemyModel end))
	
end

return Model