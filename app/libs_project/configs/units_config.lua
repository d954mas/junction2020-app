---@class UnitSpineConfig
---@field idles IdleConfig[]
---@field scale number
---@field skin hash|nil

---@class IdleConfig
---@field name hash
---@field step number


local M = {}

local HERO_BATTLE_SCALE = 0.85

M.HEROES = {
	---@type UnitSpineConfig
	WARRIOR = {
		scale = 0.41 * HERO_BATTLE_SCALE,
		idles = { { step = 0, name = hash("idle") } }
	},
	SHAMAN = {
		scale = 1* HERO_BATTLE_SCALE,
		idles = { { step = 0, name = hash("idle") }, { step = 2, name = hash("idle2") }, { step = 4, name = hash("idle3") }, { step = 6, name = hash("idle4") } }
	},
	RANGER = {
		scale = 0.45* HERO_BATTLE_SCALE,
		idles = { { step = 0, name = hash("idle") }, { step = 2, name = hash("idle2") }, { step = 4, name = hash("idle3") }, }
	}
}

M.ENEMIES = {
	DRAKE_SOLDIER= {
		skin = hash("base"),
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") }, { step = 4, name = hash("idle2") } }
	},
	DRAKE_SOLDIER_ELITE= {
		skin = hash("elite"),
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") }, { step = 4, name = hash("idle2") } }
	},
	DRAKE_SOLDIER_BOSS= {
		skin = hash("boss"),
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") }, { step = 4, name = hash("idle2") } }
	},
	DRAKE_FLYER = {
		skin = hash("base"),
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") }, { step = 2, name = hash("idle2") } }
	},
	DRAKE_FLYER_ELITE = {
		skin = hash("elite"),
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") }, { step = 2, name = hash("idle2") } }
	},
	DRAKE_FLYER_BOSS = {
		skin = hash("boss"),
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") }, { step = 2, name = hash("idle2") } }
	},
	DRAKE_THUG = {
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") }, { step = 2, name = hash("idle2") } }
	},
	DRAKE_SORCERER = {
		skin = hash("base"),
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") } ,{ step = 4, name = hash("idle2") }}
	},
	DRAKE_SORCERER_ELITE = {
		skin = hash("elite"),
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") } ,{ step = 4, name = hash("idle2") }}
	},
	DRAKE_SORCERER_BOSS = {
		skin = hash("boss"),
		scale = 0.77,
		idles = { { step = 0, name = hash("idle") } ,{ step = 4, name = hash("idle2") }}
	}
}

return M