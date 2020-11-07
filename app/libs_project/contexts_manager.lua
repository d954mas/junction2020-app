local CLASS = require "libs.middleclass"
local ContextManager = require "libs.contexts_manager"

---@class ContextManagerProject:ContextManager
local Manager = CLASS.class("ContextManagerProject", ContextManager)

Manager.NAMES = {
	MAIN = "MAIN",
	DEBUG_GUI = "DEBUG_GUI",
	ERROR_GUI = "ERROR_GUI",
	MAIN_SCENE = "MAIN_SCENE",
	MAIN_SCENE_GUI = "MAIN_SCENE_GUI",
	LOSE_MODAL = "LOSE_MODAL",
	LOSE_MODAL_GUI = "LOSE_MODAL_GUI",

}

---@class ContextStackWrapperMain:ContextStackWrapper
-----@field data ScriptMain


---@return ContextStackWrapperMain
function Manager:set_context_top_main()
	return self:set_context_top_by_name(self.NAMES.MAIN)
end

return Manager()