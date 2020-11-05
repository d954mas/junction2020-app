local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local TWEEN = require "libs.tween"
local BTN_SCALE = require "libs_project.gui.button_scale"
local COLOR = require "richtext.color"

local COLORS = {
	[HAXE_WRAPPER.HERO_STATUS.UNAWAKENED] = { name = COLOR.parse_hex("#005b19") },
	[HAXE_WRAPPER.HERO_STATUS.CLOSED] = { name = COLOR.parse_hex("#c7bdac00") },
	[HAXE_WRAPPER.HERO_STATUS.AWAKENED] = { name = COLOR.parse_hex("#ff7800") },
}

---@class HeroCellView
local View = COMMON.class("HeroCellView")

---@param root url
function View:initialize(root_name, hero)
	self.root_name = root_name
	self.btn_scale = BTN_SCALE(root_name)
	self:bind_vh()
	self:init_gui()
	self:set_hero(hero or HAXE_WRAPPER.HERO_NAMES.WARRIOR)
	self.scheduler = COMMON.RX.CooperativeScheduler.create()
	local ctx = lua_script_instance.Get()
	self.subscribtion = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_UPDATED):subscribe(function()
		local id = COMMON.CONTEXT:set_context_top_by_instance(ctx)
		self:update_state()
		COMMON.CONTEXT:remove_context_top(id)
	end)
end

function View:init_gui()
end

function View:set_hero(hero)
	self.hero_name = assert(hero)
	self:update_state()
end

function View:bind_vh()
	self.vh = {
		root = gui.get_node(self.root_name .. "/root"),
		icon = gui.get_node(self.root_name .. "/icon"),
		icon_close = gui.get_node(self.root_name .. "/icon_close"),
		sleep = gui.get_node(self.root_name .. "/sleep"),
		bubble_sleep = gui.get_node(self.root_name .. "/bubble_sleep"),
		lbl_name = gui.get_node(self.root_name .. "/lbl_name"),
		bg_selected = gui.get_node(self.root_name .. "/bg_selected"),
	}
end

function View:set_input_listener(listener)
	self.btn_scale:set_input_listener(listener)
end

function View:final()
	self.subscribtion:unsubscribe()
end

function View:on_input(action_id, action)
	return self.btn_scale:on_input(action_id, action)

end

function View:update_state()
	local state = HAXE_WRAPPER.hero_get_status(self.hero_name)
	local sleep = state == HAXE_WRAPPER.HERO_STATUS.UNAWAKENED
	local is_current = self.hero_name == HAXE_WRAPPER.hero_get_current_name()
	gui.set_enabled(self.vh.bg_selected, is_current)
	self.btn_scale.scale = (state == HAXE_WRAPPER.HERO_STATUS.CLOSED or is_current) and 1 or 0.9
	--self.btn_scale:set_ignore_input(state == HAXE_WRAPPER.HERO_STATUS.CLOSED)
	gui.set_enabled(self.vh.icon, state ~= HAXE_WRAPPER.HERO_STATUS.CLOSED)
	gui.set_enabled(self.vh.icon_close, state == HAXE_WRAPPER.HERO_STATUS.CLOSED)
	gui.set_enabled(self.vh.sleep, state == HAXE_WRAPPER.HERO_STATUS.UNAWAKENED)
	gui.set_enabled(self.vh.bubble_sleep, state == HAXE_WRAPPER.HERO_STATUS.UNAWAKENED)
	gui.set_text(self.vh.lbl_name, HAXE_WRAPPER.get_i18n_hero_name(self.hero_name))
	gui.play_flipbook(self.vh.icon, "icon_" .. string.lower(self.hero_name) .. (sleep and "_sleep" or ""))
	gui.set_color(self.vh.lbl_name, COLORS[state].name)

end

return View