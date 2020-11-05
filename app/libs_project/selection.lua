local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local CTXS = COMMON.CONTEXT
local TAG = "[SELECTION]"

---@class SelectionElement
local SelectionElement = COMMON.class("SelectionElement")
function SelectionElement:initialize(config)
	self.selected = false
	self.config = config
end

function SelectionElement:select()
	self.selected = true
end
function SelectionElement:hide()
	self.selected = false
end

function SelectionElement:can_select()
	return true
end

function SelectionElement:press()

end

function SelectionElement:position_get()
	return vmath.vector3(0)
end

--return id if need custom movement
function SelectionElement:move_left()
	return self.config.move_left
end
function SelectionElement:move_right()
	return self.config.move_right
end
function SelectionElement:move_top()
	return self.config.move_top
end
function SelectionElement:move_bottom()
	return self.config.move_bottom
end

local SelectionElementReference = COMMON.class("SelectionElementReference", SelectionElement)
function SelectionElementReference:initialize(config)
	SelectionElement.initialize(self, config)
	assert(self.config.element)
end

function SelectionElementReference:select()
	self.config.element:select()
	return self.config.element
end
function SelectionElementReference:hide()
	SelectionElement.hide(self)
end

function SelectionElementReference:can_select()
	local can_select = self.config.element:can_select()
	return can_select
end

function SelectionElementReference:press()
end

function SelectionElementReference:position_get()
	local pos = vmath.vector3(999, 999, 999)
	return pos
end

---@class SelectionElementContext:SelectionElement
local SelectionElementContext = COMMON.class("SelectionElementContext", SelectionElement)
function SelectionElementContext:initialize(config)
	SelectionElement.initialize(self, config)
	assert(self.config.context)
	assert(self.config.context_data)
end

function SelectionElementContext:select()
	COMMON.i("SelectionElementContext " .. (self.config.name or "unknown") .. " select")
	SelectionElement.select(self)
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		ctx.data:selection_select(self.config.context_data())
		ctx:remove()
	end
	return self
end
function SelectionElementContext:hide()
	COMMON.i("SelectionElementContext " .. (self.config.name or "unknown") .. " hide")
	SelectionElement.hide(self)
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		ctx.data:selection_hide(self.config.context_data())
		ctx:remove()
	end
end

function SelectionElementContext:can_select()
	local can_select = false
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		can_select = ctx.data:selection_can_select(self.config.context_data())
		COMMON.i("SelectionElementContext " .. (self.config.name or "unknown") .. " can_select:" .. tostring(can_select))
		ctx:remove()
	end
	return can_select
end

function SelectionElementContext:press()
	COMMON.i("SelectionElementContext " .. (self.config.name or "unknown") .. " press")
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		ctx.data:selection_press(self.config.context_data())
		ctx:remove()
	end
end

function SelectionElementContext:position_get()
	local pos = vmath.vector3()
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		local view = ctx.data:selection_get_view(self.config.context_data())
		if (view) then
			pos = gui.get_screen_position(view)
		end
		ctx:remove()
	end
	return pos
end

--@class SelectionElementMapLevel:SelectionElement
local SelectionElementMapLevel = COMMON.class("SelectionElementMapLevel", SelectionElement)
function SelectionElementMapLevel:initialize(config)
	SelectionElement.initialize(self, config)
	assert(self.config.level_idx)
	self.config.name = "MapLevel" .. self.config.level_idx
	self.subscription = COMMON.RX.SubscriptionsStorage()
	self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.MAP_REGION_CHANGED):subscribe(
			function(event)
				if (not self.current_region) then self.current_region = 0 end
				local new_region = event.region - 1
				local region_multiplier = new_region - self.current_region
				self.current_region = new_region
				self.config.level_idx = self.config.level_idx + 15 * region_multiplier
			end))
end

function SelectionElementMapLevel:get_context_name()
	local current_region = HAXE_WRAPPER.map_region_get_by_level_id(self.config.level_idx - 1).id
	return "region_gui_" .. current_region
end

function SelectionElementMapLevel:get_data(ctx)
	local level = HAXE_WRAPPER.map_level_get_by_level_id(self.config.level_idx - 1)
	return assert(ctx.data.views.levels[level.idxInRegion + 1])
end

function SelectionElementMapLevel:select()
	COMMON.i("SelectionElementMapLevel " .. (self.config.name or "unknown") .. " select")
	SelectionElement.select(self)
	if (COMMON.CONTEXT:exist(self:get_context_name())) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self:get_context_name())
		ctx.data:selection_select(self:get_data(ctx))
		ctx:remove()
	end
	return self
end
function SelectionElementMapLevel:hide()
	COMMON.i("SelectionElementMapLevel " .. (self.config.name or "unknown") .. " hide")
	if (COMMON.CONTEXT:exist(self:get_context_name())) then
		SelectionElement.hide(self)
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self:get_context_name())
		ctx.data:selection_hide(self:get_data(ctx))
		ctx:remove()
	end
end

function SelectionElementMapLevel:can_select()
	local can_select = false
	if (COMMON.CONTEXT:exist(self:get_context_name())) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self:get_context_name())
		can_select = ctx.data:selection_can_select(self:get_data(ctx))
		COMMON.i("SelectionElementMapLevel " .. (self.config.name or "unknown") .. " can_select:" .. tostring(can_select))
		ctx:remove()
	end
	return can_select
end

function SelectionElementMapLevel:press()
	COMMON.i("SelectionElementMapLevel " .. (self.config.name or "unknown") .. " press")
	if (COMMON.CONTEXT:exist(self:get_context_name())) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self:get_context_name())
		ctx.data:selection_press(self:get_data(ctx))
		ctx:remove()
	end
end

function SelectionElementMapLevel:position_get()
	local pos = vmath.vector3()
	if (COMMON.CONTEXT:exist(self:get_context_name())) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self:get_context_name())
		local view = ctx.data:selection_get_view(self:get_data(ctx))
		if (view) then
			pos = gui.get_screen_position(view)
		end
		ctx:remove()
	end

	return pos
end

local SelectionLine = COMMON.class("SelectionLine")
function SelectionLine:initialize(elements, config)
	self.elements = assert(elements)
	self.config = config
end

--В каждый момент времени, активна одна selection scene
---@class SelectionScene
local SelectionScene = COMMON.class("SelectionScene")

function SelectionScene:initialize(lines, config)
	---@type SelectionElement[][]
	self.lines = assert(lines)
	self.by_id = {}
	for y, line in ipairs(self.lines) do
		for x, elem in ipairs(line.elements) do
			if (elem.config.name) then
				assert(not self.by_id[elem.config.name], "elem with name exist:" .. elem.config.name)
				self.by_id[elem.config.name] = { elem = elem, x = x, y = y }
			end
		end
	end
	self.element_pos = vmath.vector3(0, 0, 0)
	---@type SelectionElement
	self.selected = nil;
	self.config = assert(config)
	assert(self.config.name)
end

function SelectionScene:set_white_list(list)
	self.white_list = list
end

function SelectionScene:press()
	if (self.selected) then
		self.selected:press()
	end
end

---@param self SelectionScene
---@return SelectionElement
local check_elem_can_select = function(self, y, x)
	local line = self.lines[y]
	local elem = line.elements[x]
	if (self:element_can_select(elem)) then
		return elem
	end
end

function SelectionScene:line_find_first_element(y, x, right)
	local line = self.lines[y]
	if (right) then
		for i = x, #line.elements do
			local elem = check_elem_can_select(self, y, i)
			if (elem) then
				return elem, i, y
			end
		end
		for i = 1, x - 1 do
			local elem = check_elem_can_select(self, y, i)
			if (elem) then
				return elem, i, y
			end
		end
	else
		for i = x, 1, -1 do
			local elem = check_elem_can_select(self, y, i)
			if (elem) then
				return elem, i, y
			end
		end
		for i = #line.elements, x + 1, -1 do
			local elem = check_elem_can_select(self, y, i)
			if (elem) then
				return elem, i, y
			end
		end
	end
end

function SelectionScene:line_find_near_element(prev_view, y)
	local line = self.lines[y]
	local start_pos = prev_view:position_get()
	local result_view = nil
	local result_x = -1
	local dist_max = math.huge
	for x = 1, #line.elements do
		local elem = check_elem_can_select(self, y, x)
		if (elem) then
			local end_pos = elem:position_get()
			local dist = vmath.length(end_pos - start_pos)
			if (dist < dist_max) then
				dist_max = dist
				result_view = elem
				result_x = x
			end
		end
	end
	return result_view, result_x
end

---@param element SelectionElement
function SelectionScene:element_can_select(element)
	if (self.white_list) then
		local id = element.config.name
		return self.white_list[id] and element:can_select()
	else
		return element:can_select()
	end
end

function SelectionScene:focus_move_left()
	if (self.selected) then
		local ids_to_move = self.selected:move_left()
		if (ids_to_move) then
			for _, id_to_move in ipairs(ids_to_move) do
				local elem = self.by_id[id_to_move]
				if (id_to_move and elem and self:element_can_select(elem.elem)) then
					return self:select_elem_by_id(id_to_move)
				end
			end
		end
	end
	return self:focus_move(-1, 0)
end
function SelectionScene:focus_move_right()
	if (self.selected) then
		local ids_to_move = self.selected:move_right()
		if (ids_to_move) then
			for _, id_to_move in ipairs(ids_to_move) do
				local elem = self.by_id[id_to_move]
				if (id_to_move and elem and self:element_can_select(elem.elem)) then
					return self:select_elem_by_id(id_to_move)
				end
			end
		end
	end
	return self:focus_move(1, 0)
end
function SelectionScene:focus_move_up()
	if (self.selected) then
		local ids_to_move = self.selected:move_top()
		if (ids_to_move) then
			for _, id_to_move in ipairs(ids_to_move) do
				local elem = self.by_id[id_to_move]
				if (id_to_move and elem and self:element_can_select(elem.elem)) then
					return self:select_elem_by_id(id_to_move)
				end
			end
		end
	end
	return self:focus_move(0, -1)
end
function SelectionScene:focus_move_down()
	if (self.selected) then
		local ids_to_move = self.selected:move_bottom()
		if (ids_to_move) then
			for _, id_to_move in ipairs(ids_to_move) do
				local elem = self.by_id[id_to_move]
				if (id_to_move and elem and self:element_can_select(elem.elem)) then
					return self:select_elem_by_id(id_to_move)
				end
			end
		end
	end
	return self:focus_move(0, 1)
end

function SelectionScene:focus_move(dx, dy)
	self.element_start_search_pos = self.element_start_search_pos or vmath.vector3(self.element_pos)
	--fix infinity loop
	if (self.element_start_search_pos.x == 0 and self.element_start_search_pos.y == 0) then
		self.element_start_search_pos.x = dx
		self.element_start_search_pos.y = dy
	end
	local new_y = self.element_pos.y + dy
	local new_x = self.element_pos.x + dx
	if (dy ~= 0) then
		if (new_y < 1) then
			new_y = #self.lines;
		end
		if (new_y > #self.lines) then
			new_y = 1;
		end
		if (self.selected) then
			local near_elem, near_elem_x = self:line_find_near_element(self.selected, new_y)
			if (near_elem) then
				new_x = near_elem_x
			end
		end

		new_x = math.min(new_x, #self.lines[new_y].elements)
	end
	local line = self.lines[new_y]
	if (dx ~= 0) then
		if (new_x < 1) then
			if (line.config.new_line_on_end) then
				new_y = new_y - 1
				if (new_y < 1) then
					new_y = #self.lines
				end
				line = self.lines[new_y]
				return self:focus_move(#line.elements - self.element_pos.x, new_y - self.element_pos.y)
			end
			new_x = #line.elements
		end
		if (new_x > #line.elements) then
			if (line.config.new_line_on_end) then
				new_y = new_y + 1
				if (new_y > #self.lines) then
					new_y = 1
				end
				line = self.lines[new_y]
				return self:focus_move(1 - self.element_pos.x, new_y - self.element_pos.y)
			end
			new_x = 1
		end
	end
	--print("x:" .. new_x .. " y:" .. new_y)
	local element = self.lines[new_y].elements[new_x]
	local new_x_save, new_y_save = new_x, new_y
	--print(element.config.name)
	if (not self:element_can_select(element)) then
		if (dx > 0) then
			element, new_x, new_y = self:line_find_first_element(new_y, new_x, true)
		end
		if (dx < 0) then
			element, new_x, new_y = self:line_find_first_element(new_y, new_x, false)
		end
	end

	if (not element or not self:element_can_select(element)) then
		if (dy ~= 0) then
			self.element_pos.x = new_x_save
			self.element_pos.y = new_y_save
			pprint(tostring(self.element_start_search_pos) .. " " .. tostring(self.element_pos))
			if (self.element_start_search_pos.x == self.element_pos.x and self.element_start_search_pos.y == self.element_pos.y) then
				COMMON.w("no selection", TAG)
				return
			end
			return self:focus_move(0, dy < 0 and -1 or 1)
		end
	end
	if (new_x and new_y) then
		self.element_pos.x, self.element_pos.y = new_x, new_y

		if (self.selected) then
			self.selected:hide()
		end
		self.selected = self.lines[self.element_pos.y].elements[self.element_pos.x]
		self.selected = self.selected:select()
		self.element_pos.x, self.element_pos.y = self.by_id[self.selected.config.name].x, self.by_id[self.selected.config.name].y
	end

	self.element_start_search_pos = nil
end

function SelectionScene:select_elem_by_id(id)
	local elem = self.by_id[id]
	if elem then
		self:hide(true)
		self:focus_move(elem.x, elem.y)
	else
		COMMON.w("no elem with id:" .. id, TAG)
	end
end

function SelectionScene:show()
	COMMON.i("SelectionScene " .. self.config.name .. " show", TAG)
	if (#self.lines == 0) then
		return
	end --empty scene
	if (not self.selected) then
		if (self.config.default) then
			local elem = self.by_id[self.config.default]
			if elem then
				self:focus_move(elem.x, elem.y)
			else
				COMMON.w("no default elem with id:" .. self.config.default, TAG)
				self:focus_move(1, 1)
			end
		else
			self:focus_move(1, 1)
		end
		--can't select element.find first available
		if (not self.selected) then
			COMMON.w("can't select element.find first available", TAG)
			for y, line in ipairs(self.lines) do
				for x, elem in ipairs(line.elements) do
					print("check elem:" .. tostring(elem.config.name) .. " " .. tostring(self:element_can_select(elem)))
					if (self:element_can_select(elem)) then
						self.element_pos.x, self.element_pos.y = 0, 0
						self:focus_move(x, y)
						return
					end
				end
			end
		end
	else
		self.selected = self.selected:select()
	end
end
function SelectionScene:hide(reset)
	COMMON.i("SelectionScene " .. self.config.name .. " hide", TAG)
	if (self.selected) then
		self.selected:hide()
	end
	if (reset) then
		self.selected = nil
		self.element_pos.x, self.element_pos.y = 0, 0
	end
end

local Selection = COMMON.class("Selection")

function Selection:initialize()
	---@type SelectionScene
	self.scene_active = nil
	self.working = HAXE_WRAPPER.game_config_speech_platform_get() == "sber"
end

function Selection:set_white_list(list)
	if (not self.working) then return end
	COMMON.i("set white list", TAG)
	self.white_list = nil
	if (list) then
		assert(#list > 0)
		self.white_list = {}
		for _, name in ipairs(list) do
			self.white_list[name] = true
		end
	end

	if (self.scene_active) then
		self.scene_active:set_white_list(self.white_list)
		local selection = self.scene_active.selected
		if (selection) then
			if (self.white_list and not self.white_list[selection.config.name]) then
				self.scene_active:select_elem_by_id(list[1])
			end
		end
	end
end

function Selection:set_active_scene(scene, config)
	if (not self.working) then return end
	config = config or {}
	if (self.scene_active) then
		self.scene_active:hide(config.prev_reset)
	end
	self.scene_active = scene
	self.scene_active:set_white_list(self.white_list)
	self.scene_active:show()
end

local SEC = function(name, ctx, f, config)
	return SelectionElementContext(COMMON.LUME.merge_table(config or {}, { context = ctx, context_data = f, name = name }))
end
local LEVEL = function(id,config)
	return SelectionElementMapLevel(COMMON.LUME.merge_table(config or {}, { level_idx = id }))
end
local DEBUG = function(name, f)
	return SelectionElementContext({ context = CTXS.NAMES.DEBUG_GUI, context_data = f, name = name })
end
local MAP_CTX = assert(CTXS.NAMES.MAP_GUI)
local MAP_DATA = function()
	return assert(CTXS:get(MAP_CTX).data)
end

local BATTLE_CTX = assert(CTXS.NAMES.BATTLE_GUI)
local BATTLE_DATA = function()
	return assert(CTXS:get(BATTLE_CTX).data)
end
local KEYBOARD_CTX = assert(CTXS.NAMES.KEYBOARD_GUI)
local KEYBOARD_DATA = function()
	return assert(CTXS:get(KEYBOARD_CTX).data)
end
local M_NOT_ENOUGH_HP_CTX = assert(CTXS.NAMES.MODAL_NOT_ENOUGH_HP)
local M_NOT_ENOUGH_HP_DATA = function()
	return assert(CTXS:get(M_NOT_ENOUGH_HP_CTX).data)
end
local M_BATTLE_BUY_HP_CTX = assert(CTXS.NAMES.MODAL_BATTLE_BUY_HP_GUI)
local M_BATTLE_BUY_HP_DATA = function()
	return assert(CTXS:get(M_BATTLE_BUY_HP_CTX).data)
end
local M_BATTLE_WIN_CTX = assert(CTXS.NAMES.MODAL_WIN_GUI)
local M_BATTLE_WIN_DATA = function()
	return assert(CTXS:get(M_BATTLE_WIN_CTX).data)
end
local M_BATTLE_LOSE_CTX = assert(CTXS.NAMES.MODAL_LOSE_GUI)
local M_BATTLE_LOSE_DATA = function()
	return assert(CTXS:get(M_BATTLE_LOSE_CTX).data)
end
local M_SHOP_CTX = assert(CTXS.NAMES.MODAL_SHOP_GUI)
local M_SHOP_DATA = function()
	return assert(CTXS:get(M_SHOP_CTX).data)
end

local M_HERO_UPGRADE_CTX = assert(CTXS.NAMES.MODAL_HERO_UPGRADE_GUI)
local M_HERO_UPGRADE_DATA = function()
	return assert(CTXS:get(M_HERO_UPGRADE_CTX).data)
end

local M_HERO_UNLOCKED_CTX = assert(CTXS.NAMES.MODAL_HERO_UNLOCKED)
local M_HERO_UNLOCKED_DATA = function()
	return assert(CTXS:get(M_HERO_UNLOCKED_CTX).data)
end

local SEC_HERO_UNLOCKED = function(name, f)
	return SelectionElementContext({ context = M_HERO_UNLOCKED_CTX, context_data = assert(f), name = name })
end

local SEC_BATTLE = function(name, f)
	return SelectionElementContext({ context = BATTLE_CTX, context_data = f, name = name })
end
local SEC_KEYBOARD = function(name, f)
	return SelectionElementContext({ context = KEYBOARD_CTX, context_data = f, name = name })
end

local SEC_START_BATTLE = function(name, f,config)
	return SelectionElementContext(COMMON.LUME.merge_table(config or {},{ context = CTXS.NAMES.MODAL_START_BATTLE_GUI, context_data = assert(f), name = name }))
end

local SEC_HERO_UPGRADE = function(name, f,config)
	return SelectionElementContext(COMMON.LUME.merge_table(config or {},{ context = M_HERO_UPGRADE_CTX, context_data = assert(f), name = name }))
end
local START_BATTLE_DATA = function()
	return assert(CTXS:get(CTXS.NAMES.MODAL_START_BATTLE_GUI).data)
end

local CUSTOM = function(elem)
	return SelectionElementReference({ element = elem })
end

local KEY = function(key, name)
	--SEC_KEYBOARD_KEY
	return SelectionElementContext({ context = KEYBOARD_CTX, context_data = function()
		if type(key) == "number" then
			return assert(KEYBOARD_DATA().views.chars[key])
		else
			return assert(KEYBOARD_DATA().views["char_" .. key])
		end

	end, name = name or "KeyboardKey_" .. key })
end

local DEBUG_DATA = function()
	return assert(CTXS:get(CTXS.NAMES.DEBUG_GUI).data)
end

local LINE_BREAK = function(line)
	return SelectionLine(line, { new_line_on_end = true })
end

local LINE_NO_BREAK = function(line)
	return SelectionLine(line, { new_line_on_end = false })
end

local HERO_1_UPGRADE = SEC_HERO_UPGRADE("Hero1", function()
	return assert(M_HERO_UPGRADE_DATA().views.heroes.warrior.views.btn_action)
end)
local HERO_2_UPGRADE = SEC_HERO_UPGRADE("Hero2", function()
	return assert(M_HERO_UPGRADE_DATA().views.heroes.ranger.views.btn_action)
end)
local HERO_3_UPGRADE = SEC_HERO_UPGRADE("Hero3", function()
	return assert(M_HERO_UPGRADE_DATA().views.heroes.shaman.views.btn_action)
end)

local M = {}

function M.init()
	local GoldPanel = SelectionElementContext({ name = "GoldPanel", context = CTXS.NAMES.RESOURCES, context_data = function()
		return assert(CTXS:get(CTXS.NAMES.RESOURCES).data.views.gold)
	end })
	local LeafsPanel = SelectionElementContext({ name = "LeafsPanel", context = CTXS.NAMES.RESOURCES, context_data = function()
		return assert(CTXS:get(CTXS.NAMES.RESOURCES).data.views.leafs)
	end })
	local HpPanel = SelectionElementContext({ name = "HpPanel", context = CTXS.NAMES.RESOURCES, context_data = function()
		return assert(CTXS:get(CTXS.NAMES.RESOURCES).data.views.hp)
	end })
	HpPanel.can_select = function(self)
		local hearts = HAXE_WRAPPER.resources_hearts_get()
		local maxHearts = HAXE_WRAPPER.resources_hearts_get_max()
		if (hearts >= maxHearts) then return false end
		return SelectionElementContext.can_select(self)
	end

	local line_debug = {
		DEBUG("btnStorage", function()
			return assert(DEBUG_DATA().views.btn_storage)
		end),
		DEBUG("btnResponse", function()
			return assert(DEBUG_DATA().views.btn_response)
		end),
		DEBUG("btnContexts", function()
			return assert(DEBUG_DATA().views.btn_contexts)
		end),
		DEBUG("btnCheats", function()
			return assert(DEBUG_DATA().views.btn_cheats)
		end),
		DEBUG("btnProfile", function()
			return assert(DEBUG_DATA().views.btn_profile)
		end),
		DEBUG("btnTimeUp", function()
			return assert(DEBUG_DATA().views.btn_time_up)
		end),
		DEBUG("btnTimeDown", function()
			return assert(DEBUG_DATA().views.btn_time_down)
		end)
	}

	local line_debug2 = {
		DEBUG("btnCheatsEnable", function()
			return assert(DEBUG_DATA().views.cheats.btn_enable)
		end),
		DEBUG("btnCheatsAttack", function()
			return assert(DEBUG_DATA().views.cheats.btn_attack)
		end),
		DEBUG("btnCheatsHp1", function()
			return assert(DEBUG_DATA().views.cheats.btn_hp1)
		end),
		DEBUG("btnCheatsBoostersAdd", function()
			return assert(DEBUG_DATA().views.cheats.btn_boosters_add)
		end),
		DEBUG("btnCheatsRestoreHp1", function()
			return assert(DEBUG_DATA().views.cheats.btn_restore_hp_1)
		end),
		DEBUG("btnTestSpine", function()
			return assert(DEBUG_DATA().views.btn_test_spine)
		end),
		DEBUG("btnTestEmpty", function()
			return assert(DEBUG_DATA().views.btn_test_empty)
		end),
		DEBUG("btnCheatsSkipTutorial", function()
			return assert(DEBUG_DATA().views.cheats.btn_skip_tutorial)
		end),
		DEBUG("btnCheatsResetStorage", function()
			return assert(DEBUG_DATA().views.cheats.btn_reset_storage)
		end),
		DEBUG("btnCheatsTutorial2", function()
			return assert(DEBUG_DATA().views.cheats.btn_tutorial_2)
		end),
	}

	local line_debug3 = {
		DEBUG("btnShowLogs", function()
			return assert(DEBUG_DATA().views.btn_show_logs)
		end),
		DEBUG("btnOpenLevel", function()
			return assert(DEBUG_DATA().views.cheats.btn_open_levels)
		end),
		DEBUG("btnCheatsTutorial3", function()
			return assert(DEBUG_DATA().views.cheats.btn_tutorial_3)
		end),
	}
	local line_debug4 = {
		DEBUG("btnCheatsTutorialUpgradeHero", function()
			return assert(DEBUG_DATA().views.cheats.btn_tutorial_upgrade_hero)
		end),
		DEBUG("btnCheatsTutorial4", function()
			return assert(DEBUG_DATA().views.cheats.btn_tutorial_4)
		end),
	}
	local line_debug5 = {
		DEBUG("btnCheatsTutorial5", function()
			return assert(DEBUG_DATA().views.cheats.btn_tutorial_5)
		end),
	}
	local lines = {
		LINE_NO_BREAK(line_debug), LINE_NO_BREAK(line_debug2), LINE_NO_BREAK(line_debug3), LINE_NO_BREAK(line_debug4), LINE_NO_BREAK(line_debug5)
	}
	M.SELECTION = Selection()
	M.SCENES = {
		MapScene = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ SEC("Exp", MAP_CTX, function()
				return assert(MAP_DATA().vh.level_icon_selection_area)
			end), HpPanel, LeafsPanel, GoldPanel, SEC("BtnInfo", MAP_CTX, function()
				return MAP_DATA().views.btn_info
			end) }),
			LINE_NO_BREAK({ SEC("BtnHeroes", MAP_CTX, function()
				return assert(MAP_DATA().views.btn_heroes)
			end,{move_bottom = {"BtnPrev","MapLevel1"}}), SEC("BtnShop", MAP_CTX, function()
				return assert(MAP_DATA().views.btn_shop)
			end) }),
			LINE_NO_BREAK({ SEC("BtnPrev", MAP_CTX, function()
				return assert(MAP_DATA().views.btn_prev)
			end), SEC("BtnNext", MAP_CTX, function()
				return assert(MAP_DATA().views.btn_next)
			end) }),
			LINE_BREAK({ LEVEL(1,{move_bottom = {"MapLevel8"},move_left = {"MapLevel15"}}), LEVEL(2), LEVEL(3), LEVEL(4), LEVEL(5), LEVEL(6), LEVEL(7,{move_right = {"MapLevel8"}}) }),
			LINE_BREAK({ LEVEL(8,{move_left = {"MapLevel7"}}), LEVEL(9), LEVEL(10), LEVEL(11), LEVEL(12), LEVEL(13), LEVEL(14), LEVEL(15,{move_right = {"MapLevel1"}}), }),
			LINE_BREAK({ SEC("BtnSettings", MAP_CTX, function()
				return assert(MAP_DATA().views.btn_settings)
			end), SEC("BtnSound", MAP_CTX, function()
				return assert(MAP_DATA().views.btn_sound)
			end) })
		}), { name = "MapScene" }),
		BattleScene = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ LeafsPanel, GoldPanel, SEC_BATTLE("BtnInfo", function()
				return BATTLE_DATA().views.btn_info
			end) }),
			LINE_NO_BREAK({ SEC_BATTLE("ToMap", function()
				return BATTLE_DATA().views.btn_back
			end) }),
			LINE_NO_BREAK({ SEC_KEYBOARD("BtnKeyboard", function()
				return KEYBOARD_DATA().views.btn_show
			end)
			, SEC_BATTLE("BoosterDouble", function()
					return BATTLE_DATA().views.boosters.double_damage.view
				end)
			, SEC_BATTLE("BoosterAnychar", function()
					return BATTLE_DATA().views.boosters.any_char.view
				end)
			, SEC_BATTLE("BoosterHint", function()
					return BATTLE_DATA().views.boosters.tooltip.view
				end) }),

		}), { name = "BattleScene", default = "BtnKeyboard" }),
		BattleBuyHPModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ LeafsPanel, GoldPanel }),
			LINE_NO_BREAK({ SEC("BtnClose", M_BATTLE_BUY_HP_CTX, function()
				return assert(M_BATTLE_BUY_HP_DATA().views.btn_close)
			end) }),
			LINE_NO_BREAK({ SEC("BtnYes", M_BATTLE_BUY_HP_CTX, function()
				return assert(M_BATTLE_BUY_HP_DATA().views.btn_yes.btn)
			end) }),
			LINE_NO_BREAK({ SEC("BtnClose2", M_BATTLE_BUY_HP_CTX, function()
				return assert(M_BATTLE_BUY_HP_DATA().views.btn_give_up.btn)
			end) }),
		}), { name = "BattleBuyHPModal", default = "BtnYes" }),
		LoseModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ SEC("BtnClose", M_BATTLE_LOSE_CTX, function()
				return assert(M_BATTLE_LOSE_DATA().views.btn_close)
			end) }),
			LINE_NO_BREAK({ SEC("BtnNext1", M_BATTLE_LOSE_CTX, function()
				return assert(M_BATTLE_LOSE_DATA().views.btn_next_hearts_have.btn)
			end) }),
			LINE_NO_BREAK({ SEC("BtnNext2", M_BATTLE_LOSE_CTX, function()
				return assert(M_BATTLE_LOSE_DATA().views.btn_next_hearts_no.btn)
			end) }),
			LINE_NO_BREAK({ SEC("BtnGiveUp", M_BATTLE_LOSE_CTX, function()
				return assert(M_BATTLE_LOSE_DATA().views.btn_give_up.btn)
			end) }),
		}), { name = "LoseModal" }),
		WinModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ SEC("BtnClose", M_BATTLE_WIN_CTX, function()
				return assert(M_BATTLE_WIN_DATA().views.btn_close)
			end) }),
			LINE_NO_BREAK({ SEC("BtnNext", M_BATTLE_WIN_CTX, function()
				return assert(M_BATTLE_WIN_DATA().views.btn_next.btn)
			end) }),
		}), { name = "WinModal", default = "BtnNext" }),
		ShopModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ LeafsPanel, GoldPanel }),
			LINE_NO_BREAK({ SEC("LeafsTab", M_SHOP_CTX, function()
				return assert(M_SHOP_DATA().views.tabs.leafs.tab)
			end), SEC("MoneyTab", M_SHOP_CTX, function()
				return assert(M_SHOP_DATA().views.tabs.money.tab)
			end), SEC("BtnClose", M_SHOP_CTX, function()
				return assert(M_SHOP_DATA().vh.btn_close)
			end) }),
			LINE_NO_BREAK({
				SEC("MoneyBuy1", M_SHOP_CTX, function()
					return assert(M_SHOP_DATA().views.tabs.money.content.slots[1].button_buy)
				end),
				SEC("MoneyBuy2", M_SHOP_CTX, function()
					return assert(M_SHOP_DATA().views.tabs.money.content.slots[2].button_buy)
				end),
				SEC("MoneyBuy3", M_SHOP_CTX, function()
					return assert(M_SHOP_DATA().views.tabs.money.content.slots[3].button_buy)
				end),
				SEC("LeafsBuy1", M_SHOP_CTX, function()
					return assert(M_SHOP_DATA().views.tabs.leafs.content.slots[1].button_buy)
				end),
				SEC("LeafsBuy2", M_SHOP_CTX, function()
					return assert(M_SHOP_DATA().views.tabs.leafs.content.slots[2].button_buy)
				end),
				SEC("LeafsBuy3", M_SHOP_CTX, function()
					return assert(M_SHOP_DATA().views.tabs.leafs.content.slots[3].button_buy)
				end),


			}),
		}), { name = "ShopModal" }),
		HelpModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ SEC("BtnClose", COMMON.CONTEXT.NAMES.MODAL_HELP_GUI, function()
				return assert(COMMON.CONTEXT:get(COMMON.CONTEXT.NAMES.MODAL_HELP_GUI).data.vh.btn_close)
			end) }),
		}), { name = "HelpModal", default = "BtnClose" }),
		HeroUpgradeModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_BREAK({ LeafsPanel, GoldPanel }),
			LINE_NO_BREAK({ SEC_HERO_UPGRADE("BtnClose", function()
				return assert(M_HERO_UPGRADE_DATA().views.btn_back)
			end,{move_left = {"GoldPanel"},move_right = {"LeafsPanel"}}) }),
			LINE_NO_BREAK({
				HERO_1_UPGRADE, HERO_2_UPGRADE, HERO_3_UPGRADE
			})
		}), { name = "HeroUpgradeModal" }),
		StartBattleModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_BREAK({ LeafsPanel, GoldPanel }),
			LINE_BREAK({ SEC_START_BATTLE("btnClose", function()
				return assert(START_BATTLE_DATA().views.btn_back)
			end,{move_bottom = {"btnPlay"}}) }),
			LINE_BREAK({ SEC_START_BATTLE("btnHero1", function()
				return assert(START_BATTLE_DATA().views.cell_warrior)
			end) }),
			LINE_BREAK({ SEC_START_BATTLE("btnHero2", function()
				return assert(START_BATTLE_DATA().views.cell_ranger)
			end) }),
			LINE_BREAK({ SEC_START_BATTLE("btnHero3", function()
				return assert(START_BATTLE_DATA().views.cell_shaman)
			end) }),
			LINE_BREAK({ SEC_START_BATTLE("btnPlay", function()
				return assert(START_BATTLE_DATA().views.btn_play)
			end,{move_right = {"btnClose"}}) }),
			--{SEC_START_BATTLE("")}


		}), { name = "StartBattleModal", default = "btnPlay" }),
		NotEnoughHPModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ SEC("BtnClose", M_NOT_ENOUGH_HP_CTX, function()
				return M_NOT_ENOUGH_HP_DATA().views.btn_back
			end) }),
			LINE_NO_BREAK({ SEC("BtnAction", M_NOT_ENOUGH_HP_CTX, function()
				return M_NOT_ENOUGH_HP_DATA().vh.popup.btn_action
			end) })
		}), { name = "NotEnoughHPModal", default = "BtnAction" }),
		BattleLeaveConfirmModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({
				SEC("BtnContinue", COMMON.CONTEXT.NAMES.MODAL_BATTLE_LEAVE_CONFIRM, function()
					return COMMON.CONTEXT:get(COMMON.CONTEXT.NAMES.MODAL_BATTLE_LEAVE_CONFIRM).data.views.btn_to_battle
				end),
				SEC("BtnLeave", COMMON.CONTEXT.NAMES.MODAL_BATTLE_LEAVE_CONFIRM, function()
					return COMMON.CONTEXT:get(COMMON.CONTEXT.NAMES.MODAL_BATTLE_LEAVE_CONFIRM).data.views.btn_leave
				end)
			}),
		}), { name = "BattleLeaveConfirmModal", default = "BtnContinue" }),
		MainLeaveConfirmModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({
				SEC("BtnReturn", COMMON.CONTEXT.NAMES.MODAL_MAIN_LEAVE_CONFIRM, function()
					return COMMON.CONTEXT:get(COMMON.CONTEXT.NAMES.MODAL_MAIN_LEAVE_CONFIRM).data.views.btn_return
				end),
				SEC("BtnExit", COMMON.CONTEXT.NAMES.MODAL_MAIN_LEAVE_CONFIRM, function()
					return COMMON.CONTEXT:get(COMMON.CONTEXT.NAMES.MODAL_MAIN_LEAVE_CONFIRM).data.views.btn_leave
				end)
			}),
		}), { name = "MainLeaveConfirmModal", default = "BtnReturn" }),
		ProfileLevelUpModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({
				SEC("BtnClose", COMMON.CONTEXT.NAMES.MODAL_PROFILE_LEVEL_UP, function()
					return COMMON.CONTEXT:get(COMMON.CONTEXT.NAMES.MODAL_PROFILE_LEVEL_UP).data.views.btn_close
				end),
			}),
		}), { name = "BattleLeaveConfirmModal", default = "BtnClose" }),
		LastLevelUnlockedModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ SEC("BtnBack", CTXS.NAMES.MODAL_LAST_LEVEL_UNLOCKED, function()
				return CTXS:get(CTXS.NAMES.MODAL_LAST_LEVEL_UNLOCKED).data.views.btn_back
			end) })
		}), { name = "LastLevelUnlockedModal", default = "BtnBack" }),
		LevelClosedModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_NO_BREAK({ SEC("BtnBack", CTXS.NAMES.MODAL_LEVEL_CLOSED, function()
				return assert(CTXS:get(CTXS.NAMES.MODAL_LEVEL_CLOSED).data.views.btn_back)
			end) }),
			LINE_NO_BREAK({ SEC("BtnPlay", CTXS.NAMES.MODAL_LEVEL_CLOSED, function()
				return assert(CTXS:get(CTXS.NAMES.MODAL_LEVEL_CLOSED).data.views.btn_play)
			end) })
		}), { name = "LevelClosedModal", default = "BtnPlay" }),
		HeroUnlockedModal = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_BREAK({ SEC_HERO_UNLOCKED("BtnBack", function()
				return M_HERO_UNLOCKED_DATA().views.btn_back
			end
			) }),
			LINE_BREAK({ SEC_HERO_UNLOCKED("BtnToHouse", function()
				return M_HERO_UNLOCKED_DATA().views.btn_to_house
			end
			) })
		}), { name = "HeroUnlockedModal", default = "BtnToHouse" }),
		RegionRestrictsModal = SelectionScene(COMMON.LUME.mix_table(lines, {}), { name = "RegionRestrictsModal" }),
		AllLevelsCompletedModal = SelectionScene(COMMON.LUME.mix_table(lines, { LINE_BREAK({ SEC("BtnClose", CTXS.NAMES.MODAL_ALL_LEVELS_COMPLETED_GUI, function()
			return assert(CTXS:get(CTXS.NAMES.MODAL_ALL_LEVELS_COMPLETED_GUI).data.vh.btn_close)
		end) }) }), { name = "AllLevelsCompletedModal", default = "BtnClose" }),
		KeyboardView = SelectionScene(COMMON.LUME.mix_table({}, {
			LINE_NO_BREAK({ KEY(1), KEY(2), KEY(3), KEY(4), KEY(5), KEY(6), KEY(7), KEY(8), KEY(9), KEY(10), KEY(11), KEY(12), KEY(13) }),
			LINE_NO_BREAK({ KEY(14), KEY(15), KEY(16), KEY(17), KEY(18), KEY(19), KEY(20), KEY(21), KEY(22), KEY(23), KEY(24), KEY(25), KEY("enter") }),
			LINE_NO_BREAK({ KEY(26), KEY(27), KEY(28), KEY(29), KEY(30), KEY(31), KEY(32), KEY(33), KEY(34), KEY("delete"), KEY("enter", "KeyboardKey_enter2") }),
			LINE_NO_BREAK({ SEC_KEYBOARD("BtnKeyboard", function()
				return KEYBOARD_DATA().views.btn_show
			end) }),

		}), { name = "KeyboardView" }),
		ErrorView = SelectionScene(COMMON.LUME.mix_table(lines, {
			LINE_BREAK({ SEC("ErrorView", CTXS.NAMES.ERROR_GUI, function()
				return CTXS:get(CTXS.NAMES.ERROR_GUI).data.vh.btn_ok
			end), SEC("ErrorReport", CTXS.NAMES.ERROR_GUI, function()
				return CTXS:get(CTXS.NAMES.ERROR_GUI).data.vh.btn_report
			end) }),

		}), { name = "ErrorView" }),


	}
	setmetatable(M.SCENES.MapScene.config, { __index = function(_, k)
		if (k == "default") then
			local id = HAXE_WRAPPER.map_get_last_unlocked_level()
			local model = HAXE_WRAPPER.map_level_get_by_level_id(id)
			local idx_in_region = model.idxInRegion
			return "MapLevel" .. (idx_in_region + 1)
		end
	end })
	setmetatable(M.SCENES.LoseModal.config, { __index = function(_, k)
		if (k == "default") then
			local hearts = HAXE_WRAPPER.resources_hearts_get()
			if (hearts > 0) then
				return "BtnNext1"
			else
				return "BtnGiveUp"
			end
		end
	end })
	setmetatable(M.SCENES.HeroUpgradeModal.config, { __index = function(_, k)
		if (k == "default") then
			if (HERO_1_UPGRADE:can_select()) then
				return "Hero1"
			elseif (HERO_2_UPGRADE:can_select()) then
				return "Hero2"
			elseif (HERO_3_UPGRADE:can_select()) then
				return "Hero3"
			else
				return "BtnClose"
			end
		end
	end })
	setmetatable(M.SCENES.ShopModal.config, { __index = function(_, k)
		if (k == "default") then
			local tabs = M_SHOP_DATA().views.tabs
			if (tabs.money.tab.active) then
				return "MoneyBuy1"
			else
				return "LeafsBuy1"
			end
		end
	end })

	M.subscription = COMMON.RX.SubscriptionsStorage()
	M.subscription = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.SCENE_CHANGED):subscribe(function(data)
		local selection = M.SCENES[data.scene]
		if (selection) then
			M.SELECTION:set_active_scene(selection, { prev_reset = true })
		end
	end)
end

return M


