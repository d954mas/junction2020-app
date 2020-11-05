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
        storage = JSON.decode(  "{}")}
end

function Conv:initialize()
	self.contexts = {}
	self.user = create_base_user()
	--sys.save("game_storage",{})
	local storage = sys.load("game_storage")[1]
	if(storage)then
		self.user.storage = JSON.decode(storage)
		self.user.storage.profile.isDev = true
	end
	pprint(self.user)
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





