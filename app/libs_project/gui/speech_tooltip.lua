local COMMON = require "libs.common"
local CONSTANTS = require "libs.constants"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local RichtextLbl = require "libs_project.gui.richtext_lbl"
local TEXT_SETTINGS = require "libs.text_settings"

local Btn = COMMON.class("SpeechTooltip")

function Btn:initialize(root_name, path)
	self.vh = {
		root = gui.get_node(root_name .. (path or "/root")),
		lbl = gui.get_node(root_name .. (path or "/lbl")),
	}
	self.lbl = RichtextLbl()
	self.lbl:set_parent(self.vh.lbl)
	self.lbl:set_text_setting(TEXT_SETTINGS.get_speech_tooltip())
	self.root_name = root_name .. (path or "/root")
end


function Btn:set_text(text)
	local locale = HAXE_WRAPPER.shared_get_locale()
	local size = 2
	if (locale == "ru") then
		size = CONSTANTS.TOOLTIP_SIZE.RU
	else
		size = CONSTANTS.TOOLTIP_SIZE.EN
	end
	local sized_text = "<size=" .. size .. ">" .. text .. "</size=" .. size .. ">"
	self.lbl:set_text(sized_text)
end

function Btn:set_enabled(enable)
	gui.set_enabled(self.vh.root,enable)
end

return Btn