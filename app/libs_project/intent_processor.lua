local COMMON = require "libs.common"
local INTENTS = require "libs_project.intents"
local SM = require "libs.sm.sm"
local JSON = require "libs_project.json"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local EVENT_BUS = require "libs.event_bus"

local TAG = "IntentProcessor"

local Processor = COMMON.class("IntentProcessor")

---@param world World
function Processor:initialize(world)
    self.world = assert(world)
end

function Processor:show_scene(name, input, options)
    self.world.thread_sequence:add_action(function()
        while (SM.co) do
            coroutine.yield()
        end
        SM:show(name, input, options)
        while (SM.co) do
            coroutine.yield()
        end
    end)
end

function Processor:back()
    self.world.thread_sequence:add_action(function()
        while (SM.co) do
            coroutine.yield()
        end
        SM:back()
        while (SM.co) do
            coroutine.yield()
        end
    end)
end

function Processor:process_events_add_thread(data)
    self.world.thread_sequence:add_action(function()
        while (SM.co) do
            coroutine.yield()
        end
        self:process_events(data.response.events, data)
    end)

end

function Processor:process_modal(data)

end

function Processor:process_results(data)

end

function Processor:process(data)
    COMMON.i("process:" .. data.intent, TAG)

    if (data.response.modelResult.code == "EXIT" or data.response.modelResult.code == "EXIT_AND_SAVE") then
        if (interactive_canvas.exit) then
            interactive_canvas.exit()
            return
        end
    end

    if self:process_results(data) then
    elseif self:process_modal(data) then

    else
        if data.intent == INTENTS.INTENTS.WEBAPP_LOAD_DONE then
            self:show_scene(SM.SCENES.MAIN)
            self:process_events_add_thread(data)
            self.world.thread_sequence:add_action(function()
                while (SM.co) do
                    coroutine.yield()
                end
                if (html_utils) then
                    html_utils.hide_bg()
                end
            end)
        elseif data.intent == INTENTS.INTENTS.DEBUG_TOGGLE then
            if (data.response.modelResult.code == "SUCCESS") then
                local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.DEBUG_GUI)
                ctx.data:input_toggle_gui_visible()
                ctx:remove()
            end
            self:process_events_add_thread(data)
        elseif data.intent == INTENTS.INTENTS.MAIN_ERROR then
            global_error_data = data.response
            msg.post("main:/gui_error#error", COMMON.HASHES.MSG_GUI_ERROR_SHOW)
        else
            if (data.response.modelResult.code == "ERROR") then
                global_error_data = data.response
                msg.post("main:/gui_error#error", COMMON.HASHES.MSG_GUI_ERROR_SHOW)
            end
            self:process_events_add_thread(data)
        end
    end


    --timer check can be ignore if was sending intent at this time
    if (self.world.battle) then
        self.world.battle:check_timer_done(data)
    end
end

function Processor:process_events(events, data)
    for _, event in ipairs(events) do
        print("process event:" .. event.name .. " " .. JSON.encode(event.data))
        if event.name == "TUTORIAL_STARTED" then
            self.world.tutorials:process_tutorial_started(event.data)
        elseif event.name == "TUTORIAL_COMPLETED" then
            COMMON.i("COMPLETED: ", "DBG_TUTOR")
            self.world.tutorials:process_tutorial_completed(event.data)
        elseif event.name == "TUTORIAL_PART_CHANGED" then
            self.world.tutorials:process_tutorial_part_changed(event.data)
        elseif event.name == "LEVEL_NEW" then
            self.world.thread_sequence:add_action(function()
                self.world:level_new()
            end)
        elseif event.name == "LEVEL_MOVE_TO_NEXT" then
            self.world.level_model:move_to_next()
        elseif event.name == "LEVEL_UNIT_SPAWN" then
            self.world.level_model:units_spawn_unit(assert(event.data.id), assert(event.data.struct))
        elseif event.name == "LEVEL_UNIT_MOVE" then
            self.world.level_model:units_move_unit(assert(event.data.id), assert((event.data.roadId)))
        elseif event.name == "LEVEL_UNIT_DIED" then
            self.world.level_model:units_die_unit(assert(event.data.id))
        elseif event.name == "LEVEL_UNIT_DIED_MOVE_TO_NEXT_CASTLE" then
            self.world.level_model:units_die_unit_move_to_next_castle(assert(event.data.id))
        elseif event.name == "LEVEL_TURN_START" then
            self.world.level_model:animation_turn_start()
        elseif event.name == "LEVEL_TURN_END" then
            self.world.level_model:animation_turn_end()
        elseif event.name == "LEVEL_PLAYER_LOST" then
            self.world.thread_sequence:add_action(function()
                COMMON.COROUTINES.coroutine_wait(0.33)
            end)
            self:show_scene(SM.SCENES.LOSE_MODAL)
        elseif event.name == "LEVEL_RESTART" then
            self.world.thread_sequence:add_action(function()
                while (SM.co) do coroutine.yield() end
                self.world:level_restart()
                SM:reload_scene()
                while (SM.co) do coroutine.yield() end
            end)
        end
    end
end

return Processor