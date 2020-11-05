local COMMON = require "libs.common"
local JSON = require "libs_project.json"

---@class SharedFakeConversation
local Conv = COMMON.class("FakeConversation")

local function create_base_user()
    return {
        name = "name",
        locale = "en",
        lastSeen = nil,
        permisions = {},
        verification = "",
        storage = JSON.decode(  "{\"profile\":{\"cheatsEnabled\":true,\"conversationIdAtStart\":\"1111\",\"conversationIdCurrent\":\"1111\",\"currentVersion\":\"421\",\"tag\":\"\",\"uuid\":\"62e09997-327f-4e0a-865c-364f09141285\"},\"serverStruct\":null,\"stat\":{\"intentIdx\":408,\"startGameCounter\":89,\"version\":0},\"serverLastTime\":1.586967396797E12,\"time\":1.586967396797E12,\"timerDelta\":0,\"user\":{\"conv\":\"1111\",\"lastSeen\":\"\",\"locale\":\"en\",\"permissions\":\"\",\"verification\":\"\"},\"version\":{\"server\":\"dev\",\"time\":\"03/26/20 17:18:38\",\"version\":421}}")}
end

local function read_file(path)
	local file = io.open(path, "rb") -- r read mode and b binary mode
	if not file then return nil end
	local content = file:read "*a" -- *a or *all reads the whole file
	file:close()
	return content
end

function Conv:initialize()
	self.contexts = {}
	self.user = create_base_user()
	--sys.save("game_storage",{})
	local storage = read_file("game_storage.json")
	if(storage and storage ~= "")then
		self.user.storage = JSON.decode(storage)
		self.user.storage.profile.isDev = true
	end
	self.contexts = {
		actions_capability_interactive_canvas = { name = "actions_capability_interactive_canvas" }
	}
	self.jsons = {
		storage = nil,
		contexts = nil
	}
end

function Conv:set_context(name, lifespan, parameters)
	if (lifespan == 0) then
		self.contexts[name] = nil
	else
		self.contexts[name] = { name = name, lifespan = lifespan, parameters = parameters }
	end
end

function Conv:contexts_get_list()
	local result = {}
	for k, v in pairs(self.contexts) do
		table.insert(result, v)
	end
	return result
end

return Conv





