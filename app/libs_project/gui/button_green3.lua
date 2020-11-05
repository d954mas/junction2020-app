local COMMON = require "libs.common"
local GOOEY = require "gooey.gooey"

local Btn = COMMON.class("ButtonScale")

function Btn:initialize(root_name, path)
	self.vh = {
		root = gui.get_node(root_name .. (path or "/root")),
		lbl = gui.get_node(root_name .. "/text")
	}
	self.config = {
		pressed = { img = COMMON.HASHES.hash("btn_green_3") },
		base = { img = COMMON.HASHES.hash("btn_green_3") },
		disabled = { img = COMMON.HASHES.hash("btn_green_3_disabled") }

	}
	self.scale = 0.9
	self.template_name = root_name
	self.root_name = root_name .. (path or "/root")
	self.scale_start = gui.get_scale(self.vh.root)
	self.gooey_listener = function()
		if self.input_listener then self.input_listener() end
	end
	self.btn_refresh_f = function(button)
		local scale = self.scale_start

		if button.pressed then
			gui.set_scale(button.node, self.scale_start * self.scale)
			gui.play_flipbook(self.vh.root, self.config.pressed.img)
		else
			gui.play_flipbook(self.vh.root, self.config.base.img)
			gui.set_scale(button.node, scale)
		end

		if (self.ignore_input) then
			gui.play_flipbook(self.vh.root, self.config.disabled.img)
		end
	end
end

function Btn:set_input_listener(listener)
	self.input_listener = listener
end

function Btn:on_input(action_id, action)
	return not self.ignore_input and GOOEY.button(self.root_name, action_id, action, self.gooey_listener, self.btn_refresh_f).consumed
end

function Btn:set_enabled(enable)
	gui.set_enabled(self.vh.root, enable)
end

function Btn:set_text(text)
	gui.set_text(self.vh.lbl, text)
end

function Btn:set_ignore_input(ignore)
	self.ignore_input = ignore
	GOOEY.button(self.root_name, COMMON.HASHES.INPUT_TOUCH, { x = -1000, y = -1000 }, self.gooey_listener, self.btn_refresh_f)
end

return Btn