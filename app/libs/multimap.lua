local COMMON = require "libs.common"

local Multimap = COMMON.class("Multimap")

function Multimap:initialize() 
	self.map = {}
end

function Multimap:add(key, value)
	assert(value ~= nil)
	local temp = self.map[key]
	if (temp == nil) then
		temp = {}
	end
	table.insert(temp, value)
	self.map[key] = temp
end

function Multimap:remove(key)
	self.map[key] = nil
end

function Multimap:get(key)
	local result = self.map[key]
	if (result == nil) then
		result = {}
	end
	return result
end

return Multimap