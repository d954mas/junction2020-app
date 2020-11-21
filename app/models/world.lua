local COMMON = require "libs.common"
local SPEECH = require "libs_project.speech"
local IntentProcessor = require "libs_project.intent_processor"
local ACTIONS = require "libs.actions.actions"
local Level = require "models.level"
local WebMonetization = require "models.web_monetization"
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
	self.web_monetization = WebMonetization(self)

	---@type nil|Level
	self.level_model = nil
end

function World:level_new()
	print("create new level")
	assert(not self.level_model)
	self.level_model = Level(self)
end

function World:level_restart()
	self.level_model = nil
end

function World:update(dt)
	self.web_monetization:update(dt)
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

function World:castle_idx_to_position(idx)
	local pos_x = COMMON.CONSTANTS.CONFIG.CASTLE_PAD_BORDER + COMMON.CONSTANTS.CONFIG.CASTLE_SIZE/2
	if(idx == 0) then
		pos_x = pos_x + 230
	end
	pos_x = pos_x + (1280-COMMON.CONSTANTS.CONFIG.CASTLE_PAD_BORDER*2-COMMON.CONSTANTS.CONFIG.CASTLE_SIZE)/2*idx
	return vmath.vector3(pos_x,270,-0.8)
end

function World:road_idx_to_position(road_idx,road_part_idx)
	local y = 270
	local castle_pos = self:castle_idx_to_position(road_idx).x
	local castle_pos_next = self:castle_idx_to_position(road_idx+1).x
	local dmove = castle_pos_next-castle_pos-COMMON.CONSTANTS.CONFIG.CASTLE_SIZE-COMMON.CONSTANTS.CONFIG.ROAD_CASTLES_PAD*2
	local roads_per_move = 5
	if(road_idx==0)then
		roads_per_move = 2
	end



	local cell_size = dmove/roads_per_move

	pprint(cell_size)

	local road_pos = castle_pos + COMMON.CONSTANTS.CONFIG.ROAD_CASTLES_PAD + COMMON.CONSTANTS.CONFIG.CASTLE_SIZE/2
	road_pos = road_pos + cell_size*road_part_idx + COMMON.CONSTANTS.CONFIG.ROAD_SIZE/2

	road_pos = road_pos - cell_size

	return vmath.vector3(road_pos,y,-0.9)

end

return World()