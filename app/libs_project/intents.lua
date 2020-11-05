local M = {}

M.MESSAGES = {
	IC_ON_UPDATE = "InteractiveCanvasOnUpdate",
	IC_ON_TTS_MARK = "InteractiveCanvasOnTtsMark",
	IC_ON_LISTENING_MODE_CHANGED = "InteractiveCanvasOnListeningModeChanged",
	IC_ON_PHRASE_MATCHED = "InteractiveCanvasOnPhraseMatched",
	IC_ON_EXIT_CONTINUOUS_MATCH_MODE = "InteractiveCanvasExitContinuousMatchMode",

	KEY_PRESSED = "KeyPressed",
	SBER_ON_START = "InteractiveCanvasSberOnStart",
	SBER_ON_DATA = "InteractiveCanvasSberOnData",
	SBER_ON_REQUEST_STATE = "InteractiveCanvasOnRequestState",
}

M.TTS_MARKS = {
	START = "START",
	END = "END",
	ERROR = "ERROR"
}

M.INTENTS = {
	WEBAPP_LOAD_DONE = "webapp.load_done",

	MAIN_ERROR = "main.error",
	CHEATS_ENABLE = "cheats.enable",
	CHEATS_DISABLE = "cheats.disable",
	DEBUG_TOGGLE = "debug.toggle",
}

return M