local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local COLORS_UTILS = require "richtext.color"
local SPEECH = require "libs_project.speech"
local WEB_MONETIZATION = require "libs_project.webmonetization"

local COLORS = {
    ENABLE = vmath.vector4(1),
    DISABLE = COLORS_UTILS.parse_hex("#1a1a1a")
}

local TAG = "[WEB_MONETIZATION]"
local WebMonetization = COMMON.CLASS("WebMonetization")

---@param world World
function WebMonetization:initialize(world)
    self.world = assert(world)
    self.web_monetization = nil
end

function WebMonetization:update(dt)
    if (SPEECH.shared) then


        local web_monetization = HAXE_WRAPPER.web_monetization_is()

        if (self.web_monetization ~= web_monetization) then
            COMMON.i("change web_monetization:" .. tostring(web_monetization), TAG)
            self.web_monetization = web_monetization
            self:on_changed()
        end
    end
end

function WebMonetization:on_changed()
    if (COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.MAIN_SCENE_GUI)) then
        local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MAIN_SCENE_GUI)
        if (not self.web_monetization) then
            --disable prem features
            self.world:game_speed_set(1)
        end
        ctx.data:on_monetization_changed()
        ctx:remove()
    end
end

function WebMonetization:on_icon_clicked()

end

return WebMonetization
