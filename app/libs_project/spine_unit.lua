local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

local M = COMMON.class("SpineUnit")



---@class SpineUnitConfig
---@field url hash
---@field config UnitSpineConfig

---@param config SpineUnitConfig
function M:initialize(config)
	assert(config)
	assert(config.config)
	assert(config.url)
	self.config = config
	self.step = 0
	if (config.config.skin) then
		spine.set_skin(config.url, config.config.skin)
	end
end

function M:animate_idle(reset)
	if (reset) then self.step = 0 end
	spine.play_anim(self.config.url, self:animation_get_idle(), go.PLAYBACK_ONCE_FORWARD, { blend_duration = 0 }, function()
		self.step = self.step + 1
		self:animate_idle()
	end)
end

function M:animate_attack()
	spine.play_anim(self.config.url, "attack", go.PLAYBACK_ONCE_FORWARD, { blend_duration = 0.2 }, function()
		self:animate_idle()
	end)
end

function M:animate_super_attack()
	spine.play_anim(self.config.url, "super_attack", go.PLAYBACK_ONCE_FORWARD, { blend_duration = 0.2 }, function()
		self:animate_idle()
	end)
end

function M:animate_damaged()
	spine.play_anim(self.config.url, "damaged", go.PLAYBACK_ONCE_FORWARD, { blend_duration = 0.2 }, function()
		self:animate_idle()
	end)
end

function M:animate_lose()
	spine.play_anim(self.config.url, "lose", go.PLAYBACK_ONCE_FORWARD, { blend_duration = 0.2 })
end

function M:animate_win()
	spine.play_anim(self.config.url, "win", go.PLAYBACK_ONCE_FORWARD, { blend_duration = 0.2 })
end

function M:animation_get_idle()
	local config = self.config.config
	if (#config.idles == 1 or self.step > config.idles[#config.idles].step) then
		self.step = 0
	end
	if (not HAXE_WRAPPER.battle_is_user_turn()) then
		self.step = 0
	end
	local current_anim = config.idles[1].name
	for _, anim in ipairs(config.idles) do
		if (anim.step == self.step) then
			current_anim = anim.name
			break
		end
	end
	return current_anim
end

return M