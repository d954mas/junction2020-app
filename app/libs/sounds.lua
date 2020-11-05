local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"

local TAG = "Sound"
local Sounds = COMMON.class("Sounds")

--gate https://www.defold.com/manuals/sound/
function Sounds:initialize()
	self.gate_time = 0.1
	self.gate_sounds = {}
	self.sounds = {
		test = { name = "test", url = msg.url("main:/sounds#test"), check_tts = true },
		battle_booster_anychar = { name = "battle_booster_anychar", url = msg.url("main:/sounds#battle_booster_anychar"), check_tts = true },
		battle_booster_double_damage = { name = "battle_booster_double_damage", url = msg.url("main:/sounds#battle_booster_double_damage"), check_tts = true },
		battle_booster_tooltip = { name = "battle_booster_tooltip", url = msg.url("main:/sounds#battle_booster_tooltip"), check_tts = true },
		battle_enemy_DRAKE_FLYER_attack = { name = "battle_enemy_DRAKE_FLYER_attack", url = msg.url("main:/sounds#battle_enemy_DRAKE_FLYER_attack"), check_tts = true },
		battle_enemy_DRAKE_FLYER_damage = { name = "battle_enemy_DRAKE_FLYER_damage", url = msg.url("main:/sounds#battle_enemy_DRAKE_FLYER_damage"), check_tts = true },
		battle_enemy_DRAKE_FLYER_lose = { name = "battle_enemy_DRAKE_FLYER_lose", url = msg.url("main:/sounds#battle_enemy_DRAKE_FLYER_lose"), check_tts = true },
		battle_enemy_DRAKE_FLYER_super = { name = "battle_enemy_DRAKE_FLYER_super", url = msg.url("main:/sounds#battle_enemy_DRAKE_FLYER_super"), check_tts = true },
		battle_enemy_DRAKE_FLYER_win = { name = "battle_enemy_DRAKE_FLYER_win", url = msg.url("main:/sounds#battle_enemy_DRAKE_FLYER_win"), check_tts = true },
		battle_enemy_DRAKE_SOLDIER_attack = { name = "battle_enemy_DRAKE_SOLDIER_attack", url = msg.url("main:/sounds#battle_enemy_DRAKE_SOLDIER_attack"), check_tts = true },
		battle_enemy_DRAKE_SOLDIER_damage = { name = "battle_enemy_DRAKE_SOLDIER_damage", url = msg.url("main:/sounds#battle_enemy_DRAKE_SOLDIER_damage"), check_tts = true },
		battle_enemy_DRAKE_SOLDIER_lose = { name = "battle_enemy_DRAKE_SOLDIER_lose", url = msg.url("main:/sounds#battle_enemy_DRAKE_SOLDIER_lose"), check_tts = true },
		battle_enemy_DRAKE_SOLDIER_super = { name = "battle_enemy_DRAKE_SOLDIER_super", url = msg.url("main:/sounds#battle_enemy_DRAKE_SOLDIER_super"), check_tts = true },
		battle_enemy_DRAKE_SOLDIER_win = { name = "battle_enemy_DRAKE_SOLDIER_win", url = msg.url("main:/sounds#battle_enemy_DRAKE_SOLDIER_win"), check_tts = true },
		battle_enemy_DRAKE_SORCERER_attack = { name = "battle_enemy_DRAKE_SORCERER_attack", url = msg.url("main:/sounds#battle_enemy_DRAKE_SORCERER_attack"), check_tts = true },
		battle_enemy_DRAKE_SORCERER_damage = { name = "battle_enemy_DRAKE_SORCERER_damage", url = msg.url("main:/sounds#battle_enemy_DRAKE_SORCERER_damage"), check_tts = true },
		battle_enemy_DRAKE_SORCERER_lose = { name = "battle_enemy_DRAKE_SORCERER_lose", url = msg.url("main:/sounds#battle_enemy_DRAKE_SORCERER_lose"), check_tts = true },
		battle_enemy_DRAKE_SORCERER_super = { name = "battle_enemy_DRAKE_SORCERER_super", url = msg.url("main:/sounds#battle_enemy_DRAKE_SORCERER_super"), check_tts = true },
		battle_enemy_DRAKE_SORCERER_win = { name = "battle_enemy_DRAKE_SORCERER_win", url = msg.url("main:/sounds#battle_enemy_DRAKE_SORCERER_win"), check_tts = true },
		battle_hero_RANGER_attack = { name = "battle_hero_RANGER_attack", url = msg.url("main:/sounds#battle_hero_RANGER_attack"), check_tts = true },
		battle_hero_RANGER_damage = { name = "battle_hero_RANGER_damage", url = msg.url("main:/sounds#battle_hero_RANGER_damage"), check_tts = true },
		battle_hero_RANGER_lose = { name = "battle_hero_RANGER_lose", url = msg.url("main:/sounds#battle_hero_RANGER_lose"), check_tts = true },
		battle_hero_RANGER_super = { name = "battle_hero_RANGER_super", url = msg.url("main:/sounds#battle_hero_RANGER_super"), check_tts = true },
		battle_hero_RANGER_win = { name = "battle_hero_RANGER_win", url = msg.url("main:/sounds#battle_hero_RANGER_win"), check_tts = true },
		battle_hero_SHAMAN_attack = { name = "battle_hero_SHAMAN_attack", url = msg.url("main:/sounds#battle_hero_SHAMAN_attack"), check_tts = true },
		battle_hero_SHAMAN_damage = { name = "battle_hero_SHAMAN_damage", url = msg.url("main:/sounds#battle_hero_SHAMAN_damage"), check_tts = true },
		battle_hero_SHAMAN_lose = { name = "battle_hero_SHAMAN_lose", url = msg.url("main:/sounds#battle_hero_SHAMAN_lose"), check_tts = true },
		battle_hero_SHAMAN_super = { name = "battle_hero_SHAMAN_super", url = msg.url("main:/sounds#battle_hero_SHAMAN_super"), check_tts = true },
		battle_hero_SHAMAN_win = { name = "battle_hero_SHAMAN_win", url = msg.url("main:/sounds#battle_hero_SHAMAN_win"), check_tts = true },
		battle_hero_WARRIOR_attack = { name = "battle_hero_WARRIOR_attack", url = msg.url("main:/sounds#battle_hero_WARRIOR_attack"), check_tts = true },
		battle_hero_WARRIOR_damage = { name = "battle_hero_WARRIOR_damage", url = msg.url("main:/sounds#battle_hero_WARRIOR_damage"), check_tts = true },
		battle_hero_WARRIOR_lose = { name = "battle_hero_WARRIOR_lose", url = msg.url("main:/sounds#battle_hero_WARRIOR_lose"), check_tts = true },
		battle_hero_WARRIOR_super = { name = "battle_hero_WARRIOR_super", url = msg.url("main:/sounds#battle_hero_WARRIOR_super"), check_tts = true },
		battle_hero_WARRIOR_win = { name = "battle_hero_WARRIOR_win", url = msg.url("main:/sounds#battle_hero_WARRIOR_win"), check_tts = true },
		battle_new_word = { name = "battle_new_word", url = msg.url("main:/sounds#battle_new_word"), check_tts = true },
		battle_timer_end = { name = "battle_timer_end", url = msg.url("main:/sounds#battle_timer_end"), check_tts = true },
		battle_word_bad = { name = "battle_word_bad", url = msg.url("main:/sounds#battle_word_bad"), check_tts = true },
		battle_word_ok = { name = "battle_word_ok", url = msg.url("main:/sounds#battle_word_ok"), check_tts = true },
	}
end

function Sounds:update(dt)
	for k, v in pairs(self.gate_sounds) do
		self.gate_sounds[k] = v - dt
		if self.gate_sounds[k] < 0 then
			self.gate_sounds[k] = nil
		end
	end
end

function Sounds:play_sound(sound_obj)
	assert(sound_obj)
	assert(type(sound_obj) == "table")
	assert(sound_obj.url)

	if(sound_obj.check_tts)then
		if(SPEECH.tts_playing)then
			COMMON.i("tts_playing sound:" .. sound_obj.name, TAG)
			return
		end
	end

	if not self.gate_sounds[sound_obj] then
		self.gate_sounds[sound_obj] = self.gate_time
		sound.play(sound_obj.url)
		COMMON.i("play sound:" .. sound_obj.name, TAG)
	else
		COMMON.i("gated sound:" .. sound_obj.name .. "time:" .. self.gate_sounds[sound_obj], TAG)
	end
end

return Sounds()