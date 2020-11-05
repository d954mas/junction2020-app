local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local IntentProcessor = require "libs_project.intent_processor"
local ACTIONS = require "libs.actions.actions"
---@class World
local World = COMMON.class("World")

function World:initialize()
	self.speech = SPEECH
	self.intent_processor = IntentProcessor(self)
	self.speech:set_world(self)
	self.thread = COMMON.ThreadManager()
	self.thread_sequence = ACTIONS.Sequence()
	self.thread_sequence.drop_empty = false
	self.thread:add(self.thread_sequence)
	self.scheduler = COMMON.RX.CooperativeScheduler.create()
	self.subscription = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_UPDATED):go(self.scheduler):subscribe(function()
		self:storage_changed()
	end)
end

function World:update(dt)
	self.thread:update(dt)
	self.scheduler:update(dt)
end

function World:storage_changed()
end
--endregion


function World:speech_process_intent(msg)
	self.intent_processor:process(msg)
end

return World()