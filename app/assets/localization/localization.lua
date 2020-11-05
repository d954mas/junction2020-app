local I18N = require "libs.i18n.init"
local COMMON = require "libs.common"
local TAG = "LOCALIZATION"
local LOCALES = { "en", "ru" }
local DEFAULT = "en"
local FALLBACK = "en"

---@class Localization
local M = {
	skill_ANGER_name = { en = "Anger", ru = "Ярость" },
	skill_ANGER_dscr = { en = "current attack deal 200% damage", ru = "текущая атака наносит 200% урона" },
	skill_FOREST_KNOWLEGE_name = { en = "FOREST_KNOWLEGE", ru = "Ярость" },
	skill_FOREST_KNOWLEGE_dscr = { en = "remove all debuffs from chars. Deal damage for every char with debuff",
								   ru = "удалить все дебаффы из символов. Наносит урон для каждого персонажа с дебаффом" },
	skill_WISDOM_OF_THE_ANCESTORS_name = { en = "WISDOM_OF_THE_ANCESTORS", ru = "Ярость" },
	skill_WISDOM_OF_THE_ANCESTORS_dscr = { en = "one more turn", ru = "еще один ход" },


	enemy_DRAKE_SOLDIER_skill_dscr = { en = " ", ru = " " },
	enemy_DRAKE_FLYER_skill_dscr = { en = "Every 2 turn.Made Random char in base word blocked.You can use blocked char.(use near char to that char to unblock it)",
									 ru = "Каждые 2 хода. Сделано случайным символом в базовом слове заблокировано. Вы можете использовать заблокированный символ. (Используйте рядом с этим символом, чтобы разблокировать его)" },
	enemy_DRAKE_THUG_skill_dscr = { en = "ignore damage from words with 3 chars and less.", ru = "игнорировать урон от слов с 3 символами и меньше." },
	enemy_DRAKE_SORCERER_skill_dscr = { en = "Every 2 turn.Made Random char in base word weak.Char power -1(use Ranger skill to remove it)",
										ru = "Каждые 2 хода. Сделано случайным символом в слабом базовом слове. Сила символа -1 (используйте умение Рейнджер, чтобы удалить его)" },
}

function M:locale_exist(key)
	local locale = self[key]
	if not locale then
		COMMON.w("key:" .. key .. " not found", TAG)
	end
end

function M:set_locale(locale)
	I18N.setLocale(locale)
end

I18N.setFallbackLocale(FALLBACK)
I18N.setLocale(DEFAULT)

for _, locale in ipairs(LOCALES) do
	local table = {}
	for k, v in pairs(M) do
		if type(v) ~= "function" then
			table[k] = v[locale]
		end
	end
	I18N.load({ [locale] = table })
end

for k, v in pairs(M) do
	if type(v) ~= "function" then
		M[k] = function(data)
			return I18N(k, data)
		end
	end
end

--return key if value not founded
local t = setmetatable({ __VALUE = M, }, {
	__index = function(_, k)
		local result = M[k]
		if not result then
			COMMON.w("no key:" .. k, TAG)
			result = function() return k end
			M[k] = result
		end
		return result
	end,
	__newindex = function() error("table is readonly", 2) end,
})

--fix cycle dependencies
COMMON.LOCALE = t

return t
