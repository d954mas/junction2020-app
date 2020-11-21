local SM = require "libs.sm.scene_manager"
--MAIN SCENE MANAGER

local sm = SM()

sm.SCENES = {
    MAIN = "MainScene",
    LOSE_MODAL = "LoseModal",
    WIN_MODAL = "WinModal",
    HELP_MODAL = "HelpModal"
}

return sm