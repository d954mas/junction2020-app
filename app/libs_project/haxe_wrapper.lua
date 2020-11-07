local SPEECH = require "libs_project.speech"
local SHARED = require "libs_project.shared"
local INTENTS = require "libs_project.intents"
local LOG = require "libs.log"
local JSON = require "libs_project.json"
local HAXE_RESTRICTIONS = SHARED.shared.project.model.Restrictions

local TAG = "HAXE_WRAPPER"

local M = {}


function M.get_world()
	return SPEECH.shared.world
end

function M.shared_get_locale()
	return M.get_world().storage.user.locale
end

function M.context_exist(name)
	return M.get_world():contextExist(name)
end


function M.tutorial_is_completed(id)
	local tutorial = M.get_world().storage.tutorials[id]
	if not tutorial then
		LOG.w("unknown tutorial:" .. id)
		return false
	end
	return tutorial.completed
end

function M.tutorial_is_in_progress(id)
	local tutorial = M.get_world().storage.tutorials[id]
	if not tutorial then
		LOG.w("unknown tutorial:" .. id)
		return false
	end
	return tutorial.currentPart ~= nil
end

function M.tutorial_get_active()
	local result = {}
	local haxeResult = M.get_world().tutorialsModel:tutorialsDebugGetActive()
	for i = 0, haxeResult.length - 1 do
		table.insert(result, haxeResult[i])
	end
	return result
end


function M.can_process_intent(name)
	return M.get_world():canProcessIntent(name)
end

function M.get_i18n_text(id, params)
	return M.get_world():getLocalizationLua(id, params and JSON.encode(params))
end

function M.get_i18n_tutorial_text(id, params)
	return M.get_world():getLocalizationLuaTutorial(id, params and JSON.encode(params))
end


function M.user_get_uuid()
	return assert(M.get_world().storage.profile.uuid)
end

function M.user_is_dev()
	return M.get_world().storage.profile.isDev;
end

function M.game_config_speech_platform_get()
	return SHARED.shared.project.configs.GameConfig.PLATFORM
end


function M.level_castle_get_by_idx(idx)
	return M.get_world().levelModel:castlesGetByIdx(idx)
end

function M.level_units_get_by_id(idx)
	return M.get_world().levelModel:unitsGetByIdx(idx)
end

function M.level_castles_get_array()
	return M.get_world().storage.level.castles
end

function M.level_road_get_by_idx(idx)
	return M.get_world().levelModel:roadsGetByIdx(idx)
end
function M.level_roads_get_array()
	return M.get_world().storage.level.roads
end

function M.resources_get_money()
	return M.get_world().storage.level.player.money
end
function M.resources_get_mana()
	return M.get_world().storage.level.player.mana
end
return M





