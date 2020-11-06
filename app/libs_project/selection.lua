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

local CUSTOM = function(elem)
	return SelectionElementReference({ element = elem })
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


local M = {}

function M.init()

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


