local CLASS = require "libs.middleclass"
local ContextManager = require "libs.contexts_manager"

---@class ContextManagerProject:ContextManager
local Manager = CLASS.class("ContextManagerProject", ContextManager)

Manager.NAMES = {
	MAIN = "MAIN",
	MAP = "MAP",
	MAP_GUI = "MAP_GUI",
	BATTLE_GUI = "BATTLE_GUI",
	BATTLE_GUI_TOP = "BATTLE_GUI_TOP",
	KEYBOARD_GUI = "KEYBOARD_GUI",
	BATTLE_GUI_WORDS = "BATTLE_GUI_WORDS",
	BATTLE_SCENE = "BATTLE_SCENE",
	MODAL_BATTLE_BUY_HP_GUI = "MODAL_BATTLE_BUY_HP_GUI",
	MODAL_NOT_ENOUGH_HP = "MODAL_NOT_ENOUGH_HP",
	MODAL_LAST_LEVEL_NEED_STARS_MODAL = "MODAL_LAST_LEVEL_NEED_STARS_MODAL",
	MODAL_LEVEL_CLOSED = "MODAL_LEVEL_CLOSED",
	MODAL_LAST_LEVEL_UNLOCKED = "MODAL_LAST_LEVEL_UNLOCKED",
	MODAL_NOT_ENOUGH_STONES = "MODAL_NOT_ENOUGH_STONES",
	MODAL_NOT_ENOUGH_MONEY = "MODAL_NOT_ENOUGH_MONEY",
	MODAL_WIN_GUI = "MODAL_WIN_GUI",
	MODAL_LOSE_GUI = "MODAL_LOSE_GUI",
	MODAL_SHOP_GUI = "MODAL_SHOP_GUI",
	MODAL_HELP_GUI = "MODAL_HELP_GUI",
	MODAL_SERVER_WORK_GUI = "MODAL_SERVER_WORK_GUI",
	MODAL_ALL_LEVELS_COMPLETED_GUI = "MODAL_ALL_LEVELS_COMPLETED_GUI",
	MODAL_HERO_UPGRADE_GUI = "MODAL_HERO_UPGRADE_GUI",
	MODAL_START_BATTLE_GUI = "MODAL_START_BATTLE_GUI",
	MODAL_PROFILE_LEVEL = "MODAL_PROFILE_LEVEL",
	MODAL_PROFILE_LEVEL_UP = "MODAL_PROFILE_LEVEL_UP",
	MODAL_BATTLE_LEAVE_CONFIRM = "MODAL_BATTLE_LEAVE_CONFIRM",
	MODAL_MAIN_LEAVE_CONFIRM = "MODAL_MAIN_LEAVE_CONFIRM",
	MODAL_HERO_UNLOCKED = "MODAL_HERO_UNLOCKED",
	MODAL_HERO_AWAKEN = "MODAL_HERO_AWAKEN",
	MODAL_HERO_LVL_UP = "MODAL_HERO_LVL_UP",
	MODAL_REGION_RESTRICTS = "MODAL_REGION_RESTRICTS",
	TUTORIAL_BUBBLES = "TUTORIAL_BUBBLES",
	INFO_BUBBLES = "INFO_BUBBLES",
	RESOURCES = "RESOURCES",
	DEBUG_GUI = "DEBUG_GUI",
	ERROR_GUI = "ERROR_GUI",
}

---@class ContextStackWrapperMain:ContextStackWrapper
-----@field data ScriptMain

---@class ContextStackWrapperMap:ContextStackWrapper
-----@field data MapGuiScript

---@return ContextStackWrapperMain
function Manager:set_context_top_main()
	return self:set_context_top_by_name(self.NAMES.MAIN)
end
---@return ContextStackWrapperMap
function Manager:set_context_top_map()
	return self:set_context_top_by_name(self.NAMES.MAP)
end
---@return ContextStackWrapperMain
function Manager:set_context_top_battle_scene()
	return self:set_context_top_by_name(self.NAMES.BATTLE_SCENE)
end

---@class ContextStackWrapperBattleGui:ContextStackWrapper
---@field data BattleGuiScript

---@return ContextStackWrapperBattleGui
function Manager:set_context_top_battle_gui()
	return self:set_context_top_by_name(self.NAMES.BATTLE_GUI)
end
---@class ContextStackWrapperBattleGuiTop:ContextStackWrapper
---@field data BattleGuiTopScript
---
---@return ContextStackWrapperBattleGuiTop
function Manager:set_context_top_battle_gui_top()
	return self:set_context_top_by_name(self.NAMES.BATTLE_GUI_TOP)
end

---@class ContextStackWrapperKeyboardGui:ContextStackWrapper
---@field data KeyboardGuiScript

---@return ContextStackWrapperBattleGui
function Manager:set_context_top_keyboard_gui()
	return self:set_context_top_by_name(self.NAMES.KEYBOARD_GUI)
end


---@class ContextStackWrapperModalWin:ContextStackWrapper
---@field data ModalWinGUIScript

---@return ContextStackWrapperModalWin
function Manager:set_context_top_modal_win()
	return self:set_context_top_by_name(self.NAMES.MODAL_WIN_GUI)
end

---@class ContextStackWrapperModalLose:ContextStackWrapper
---@field data ModalLoseGUIScript

---@return ContextStackWrapperModalLose
function Manager:set_context_top_modal_lose()
	return self:set_context_top_by_name(self.NAMES.MODAL_LOSE_GUI)
end

---@class ContextStackWrapperBattleBuyHPWin:ContextStackWrapper
---@field data ModalBattleBuyHPGUIScript

---@return ContextStackWrapperBattleBuyHPWin
function Manager:set_context_top_modal_battle_buy_hp_gui()
	return self:set_context_top_by_name(self.NAMES.MODAL_BATTLE_BUY_HP_GUI)
end

---@class ContextStackWrapperModalShop:ContextStackWrapper
---@field data ModalShopGUIScript

---@return ContextStackWrapperModalShop
function Manager:set_context_top_modal_shop()
	return self:set_context_top_by_name(self.NAMES.MODAL_SHOP_GUI)
end

---@class ContextStackWrapperModalHeroUpgrade:ContextStackWrapper
---@field data ModalHeroUpgradeGUIScript

---@return ContextStackWrapperModalHeroUpgrade
function Manager:set_context_top_modal_hero_upgrade()
	return self:set_context_top_by_name(self.NAMES.MODAL_HERO_UPGRADE_GUI)
end

---@class ContextStackWrapperModalStartBattle:ContextStackWrapper
---@field data ModalStartBattleGUIScript

---@return ContextStackWrapperModalStartBattle
function Manager:set_context_top_modal_start_battle()
	return self:set_context_top_by_name(self.NAMES.MODAL_START_BATTLE_GUI)
end

---@class ContextStackWrapperInfoBubble:ContextStackWrapper
---@field data InfoBubbleGUIScript

---@return ContextStackWrapperInfoBubble
function Manager:set_context_top_info_bubble()
	return self:set_context_top_by_name(self.NAMES.INFO_BUBBLES)
end

---@class ContextStackWrapperResources:ContextStackWrapper
---@field data InfoBubbleGUIScript

---@return ContextStackWrapperResources
function Manager:set_context_top_resources()
	return self:set_context_top_by_name(self.NAMES.RESOURCES)
end

---@class ContextStackWrapperTutorialBubbles:ContextStackWrapper
---@field data TutorialBubblesGUIScript

---@return ContextStackWrapperTutorialBubbles
function Manager:set_context_top_tutorial_bubbles()
	return self:set_context_top_by_name(self.NAMES.TUTORIAL_BUBBLES)
end

return Manager()