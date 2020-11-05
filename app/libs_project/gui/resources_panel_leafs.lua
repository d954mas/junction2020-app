local COMMON = require "libs.common"
local GOOEY = require "gooey.gooey"
local SPEECH = require "libs_project.speech"
local INTENTS = require "libs_project.intents"

local ResourcePanel = require "libs_project.gui.resources_panel"

---@class ResourcesPanelLeafs:ResourcesPanel
local Btn = COMMON.class("ResourcesPanelLeafs", ResourcePanel)

function Btn:resource_get_value()
	return SPEECH.shared.world.storage.resources.stones
end

function Btn:on_btn_plus_clicked()
	interactive_canvas.send_text_query(INTENTS.INTENTS.SHOP_SHOW_STONES)
end

return Btn