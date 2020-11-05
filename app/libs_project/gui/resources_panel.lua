local COMMON = require "libs.common"
local GOOEY = require "gooey.gooey"

local BtnScale = require "libs_project.gui.button_scale"

---@class ResourcesPanel
local Btn = COMMON.class("ResourcesPanel")

function Btn:initialize(root_name)
	self.vh = {
		root = gui.get_node(root_name .. "/root"),
		text = gui.get_node(root_name .. "/text"),
		plus = gui.get_node(root_name .. "/plus"),
		bg = gui.get_node(root_name .. "/bg"),
	}
	self.views = {
		btn_plus = BtnScale(root_name, "/root")
	}
	self.views.btn_plus.scale = 1
	self.root_name = root_name .. "/root"
	self.views.btn_plus:set_input_listener(function()
		self:on_btn_plus_clicked()
	end)
end

function Btn:resource_get_value()
	return ""
end

function Btn:set_enabled(enabled)
	gui.set_enabled(self.vh.root, enabled)
end

function Btn:on_btn_plus_clicked() end

function Btn:update(dt)
	gui.set_text(self.vh.text, self:resource_get_value())
end

function Btn:on_input(action_id, action)
	return self.views.btn_plus:on_input(action_id, action)
end

return Btn