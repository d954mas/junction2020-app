local JSON = require "cjson"

local file = io.open( "junctiongame/version.json", "r" )
assert(file)
local contents = file:read( "*a" )
file:close()
local data = JSON.decode(contents)

data.version = data.version + 1
data.time = os.date("%x %X", os.time())


file =  io.open( "junctiongame/version.json", "w" )
assert(file)
file:write(JSON.encode(data))
file:close()
return true
