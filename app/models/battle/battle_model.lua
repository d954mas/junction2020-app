local COMMON = require "libs.common"
local LevelModel = require "models.battle.unit.level_model"
local BattleView = require "scenes.battle.view.battle_view"
local CommandsExecutor = require "scenes.battle.commands.command_executor"
local INTENTS = require "libs_project.intents"
local COMMANDS = require "scenes.battle.commands.commands"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
---@class BattleModel
local Battle = COMMON.class("BattleModel")

---@param world World
function Battle:initialize(world)
    self.world = world
    self.haxe_battle_model = COMMON.meta_getter(function()
        return self.world.speech.shared.world.battleModel
    end)
    self.haxe_battle_storage = COMMON.meta_getter(function()
        return self.world.speech.shared.world.storage.battle
    end)
    self.user_turn_in_view = true

    self.level_model = LevelModel(self.world)
    self.word_current = nil
    self.word_effects = nil
    self.words_played = {}
    self.word_say = nil
    self.stat = {
        hero_turn_damage = 0
    }
    self.timer_end = "NO TIMER"
    self.scheduler = COMMON.RX.CooperativeScheduler.create()
    self.subscriptions = COMMON.RX.SubscriptionsStorage()
    self.subscriptions:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_UPDATED):go(self.scheduler):subscribe(function()
        self:storage_changed()
        self.world.battle.view.views.hero_speech_bubble:hide_dots()
    end))
    self.subscriptions:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.CONTINUOUS_MODE_MATCHED):go(self.scheduler):subscribe(function(data)
        self:continuous_matched(data)
    end))
    self.view = BattleView(self)

    self.commands = CommandsExecutor()
    self.skill_sequence = {}
end

function Battle:continuous_matched(data)
    print("continuous_matched")
    assert(data)
    local result = assert(data.phraseMatchResult)
    pprint(result)
    if (result.isFinal) then
        local word = result.hypothesisMatchSets[1]
        if (word) then
            local text = word.phrases[1]
            self.world.battle.view.views.hero_speech_bubble:show_dots()
            interactive_canvas.send_text_query(text)
        end
    end
end

function Battle:word_base_changed(word)
    self.word_prev = self.word_current
    self.word_current = word
    self.view:word_base_changed(self.word_current)
end

function Battle:word_change_battle_mechanics(word)
    self.word_prev = self.word_current
    self.word_current = word
    self.view:word_change_battle_mechanics(self.word_current)
end

function Battle:update(dt)
    if self.haxe_battle_storage.wordCurrent then
        self.word_current = self.haxe_battle_storage.wordCurrent
        self.word_effects = self.haxe_battle_storage.wordCurrentCharEffect
        self.words_played = self.haxe_battle_storage.wordsPlayed
    end
    if (self.timer_end ~= self.haxe_battle_storage.timerUserTurnEnd) then
        self.timer_end = self.haxe_battle_storage.timerUserTurnEnd
        self:check_timer_done()
    end
    self.scheduler:update(dt)
    self.view:update(dt)
    self.commands:act(dt)
end

function Battle:storage_changed()
    self.view:storage_changed()
end

function Battle:start_timer()
    HAXE_WRAPPER.battle_timer_clear()
    self.world.speech.shared.world.timers:resetBattleTimer();
end

function Battle:is_active()
    local state = self.world.speech.shared.world.storage.battle.state
    return state ~= "WIN" and state ~= "LOSE"
end

function Battle:is_turn_enemy()
    return self.world.speech.shared.world.storage.battle.state == "ENEMY_TURN"
end

function Battle:is_turn_user()
    return self.world.speech.shared.world.storage.battle.state == "USER_TURN"
end

function Battle:check_timer_done(data)
    if (data and data.intent == INTENTS.INTENTS.BATTLE_USER_SAY_WORD and data.response.modelResult.code == "SUCCESS") then
        self.world.speech.shared.world.timers:endBattleTimer();
        if (self:is_turn_user()) then
            self:start_timer()
        end
    end
    if (data and data.intent == INTENTS.INTENTS.MAP_START_BATTLE and data.response.modelResult.code == "SUCCESS") then
        self.world.speech.shared.world.timers:endBattleTimer();
    end
    if (data and data.intent == INTENTS.INTENTS.BATTLE_USER_TURN_END and data.response.modelResult.code == "SUCCESS") then
        self.world.speech.shared.world.timers:endBattleTimer();
    end
    if (data and data.intent == INTENTS.INTENTS.BATTLE_ENEMY_SAY_WORD and data.response.modelResult.code == "SUCCESS") then
        self.world.speech.shared.world.timers:endBattleTimer();
    end

    if (data and data.intent == INTENTS.INTENTS.BATTLE_BOOSTER_TOOLTIP and data.response.modelResult.code == "SUCCESS") then
        self.world.speech.shared.world.timers:endBattleTimer();
        if (self:is_turn_user()) then
            self:start_timer()
        end
    end

    if (data and data.intent == INTENTS.INTENTS.CHEATS_ATTACK and data.response.modelResult.code == "SUCCESS") then
        self.world.speech.shared.world.timers:endBattleTimer();
    end

    if (data and data.intent == INTENTS.INTENTS.BATTLE_HP_RESTORE_YES and data.response.modelResult.code == "SUCCESS") then
        self.world.speech.shared.world.timers:endBattleTimer();
    end
    print("check timer")
    print(self.timer_end)

    if (data and data.intent == INTENTS.INTENTS.BATTLE_USER_SAY_WORD and data.response.modelResult.code ~= "SUCCESS"
            and (self.timer_end == "DONE" or self.timer_end == "CAN_RESTART") and not self.timer_sending) then
        self.timer_sending = true
        self.world.speech.shared.world.timers:endBattleTimer();
        --Нужно запоминат текущий ход.НСли он остался такимже то повторить отправку.
        self.commands:command_add(COMMANDS.BattleUserTurnEndCommand);
    end
    if (self.timer_end == "DONE" and not self.timer_sending) then
        self.world.speech.shared.world.timers:endBattleTimer();
        self.commands:command_add(COMMANDS.BattleUserTurnEndCommand);
        self.timer_sending = true

    end
end

function Battle:process_intent_before()

end

function Battle:process_intent_after()
    --VSP-804
    --Гооврим слово, оно отправляется. Таймер заканчивается и он тоже отправляется.
    --В итоге уходит две команды, конец хода и получаем двойную атаку тролля
    self.timer_sending = false
end

function Battle:dispose()
    self.view:dispose()
    self.subscriptions:unsubscribe()
end

return Battle