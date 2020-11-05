local M = {}

M.DEBUG_HTML = false
M.SBERBANK = false
M.SYSTEM_NAME = sys.get_sys_info().system_name
M.ANDROID = M.SYSTEM_NAME == "Android"
M.HTML5 = M.SYSTEM_NAME == "HTML5"
M.INTERACTIVE_CANVAS = not M.SBERBANK and (M.HTML5 and not M.DEBUG_HTML)
M.INTERACTIVE_CANVAS_SBERBANK = M.SBERBANK and M.HTML5 and not M.DEBUG_HTML
M.REST_CANVAS =  M.SYSTEM_NAME == "Android"
M.FAKE_CANVAS = false
--M.FAKE_CANVAS_DELAY = { min = 0.5, max = 2 }
M.FAKE_CANVAS_DELAY = { min = 0, max = 0 }
M.TOOLTIP_SIZE = {
	EN = 0.6,
	RU = 0.5,
}

M.GUI_ORDER = {
	RESOURCES = 10,
	HEROES_UPGRADE = 4, KEYBOARD = 14,
	SELECT_CLOSED_LEVEL = 5,
	HELP = 8,
	TUTORIAL_BUBBLES = 13,
	BUBBLES = 12,
	DEBUG = 16,
	MODAL_3 = 3,
	MODAL_4 = 4,
	MODAL_5 = 5,
	MODAL_LEAVE = 15,
}

M.GAME_SIZE = {
	width = 1280,
	height = 680
}

M.FACTORIES = {
	BATTLE_CHAR = msg.url("battle:/words/factories#/factory_char")
}

M.URL = {
	BATTLE = {
		WORD_MAIN_CTR = msg.url("battle:/word_main_ctr")
	}
}
M.SHOP_TABS = {
	MONEY = "money",
	STONES = "stones",
	ITEMS = "items"
}

return M
