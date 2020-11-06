local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local IntentProcessor = require "libs_project.intent_processor"
local ACTIONS = require "libs.actions.actions"
local Level = require "models.level"
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

	---@type nil|Level
	self.level_model = nil
end

function World:level_new()
	print("create new level")
	assert(not self.level_model)
	self.level_model = Level(self)
end

function World:update(dt)
	if(self.level_model)then
		self.level_model:update(dt)
	end
	self.thread:update(dt)
	self.scheduler:update(dt)
end

function World:storage_changed()
	if(self.level_model)then
		self.level_model:storage_changed()
	end
end
--endregion


function World:speech_process_intent(msg)
	self.intent_processor:process(msg)
end

return World()