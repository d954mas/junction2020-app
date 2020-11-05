local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local TEXT_SETTINGS = require "libs.text_settings"
local COLOR = require "richtext.color"
local RichtextLbl = require "libs_project.gui.richtext_lbl"

local Btn = COMMON.class("MapPlayTooltip")

function Btn:initialize(root_name, path)
	self.vh = {
		root = gui.get_node(root_name .. (path or "/root")),
		lbl_pos = gui.get_node(root_name .. "/lbl_pos")
	}
	self.root_name = root_name .. (path or "/root")
	self.lbl = RichtextLbl()
	self.lbl:set_text_setting( TEXT_SETTINGS.make_copy(TEXT_SETTINGS.SHOWCARD, { color = COLOR.parse_hex("#9e8a5f") }))
	self.lbl:set_parent(self.vh.lbl_pos)
	self.lbl:set_text(HAXE_WRAPPER.get_i18n_text("client/speech_tooltip_play_level"))
	gui.animate(self.vh.root, "scale", vmath.vector3(1.1), gui.EASING_LINEAR, 1.2, 0, nil, gui.PLAYBACK_LOOP_PINGPONG)
end

function Btn:set_position(pos)
	gui.set_position(self.vh.root, pos+vmath.vector3(24,38,0))
end

function Btn:set_enabled(enable)
	gui.set_enabled(self.vh.root, enable)
end

return Btn