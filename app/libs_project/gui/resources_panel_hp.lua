local COMMON = require "libs.common"
local SHARED = require "libs_project.shared"
local SPEECH = require "libs_project.speech"
local INTENTS = require "libs_project.intents"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

local ResourcePanel = require "libs_project.gui.resources_panel"

---@class ResourcesPanelHP:ResourcesPanel
local Btn = COMMON.class("ResourcesPanelHP", ResourcePanel)

function Btn:initialize(root_name)
	ResourcePanel.initialize(self, root_name)
	self.vh.lbl_hp = gui.get_node(root_name .. "/hp_lbl")
	self.views.btn_plus.scale = 0.9
end

function Btn:resource_get_value()
	if(not SPEECH.shared) then
		return ""
	end		
	local value = math.ceil(SPEECH.shared.world.storage.timers.hpTimer.timeLeft / 1000)
	if (value == 0) then return HAXE_WRAPPER.get_i18n_text("client/hearts_max") end
	local minutes = math.floor(value / 60)
	local seconds = value - minutes * 60
	if (seconds < 10) then
		seconds = "0" .. seconds
	end
	return minutes .. ":" .. seconds
end

function Btn:on_btn_plus_clicked()
	interactive_canvas.send_text_query(INTENTS.INTENTS.MODAL_NOT_ENOUGH_HP_SHOW)
end

function Btn:update(dt)
	ResourcePanel.update(self, dt)
	if(not SPEECH.shared) then
		return 
	end		
	local show_plus = SPEECH.shared.world.storage.resources.hp < SHARED.shared.project.configs.GameConfig.MAX_HP
	gui.set_enabled(self.vh.plus,show_plus)
	gui.set_enabled(self.vh.bg,true)
	self.views.btn_plus:set_ignore_input(not show_plus)
	gui.set_text(self.vh.lbl_hp, SPEECH.shared.world.storage.resources.hp)
end
function Btn:on_input(action_id, action)
	return self.views.btn_plus:on_input(action_id, action)
end


return Btn