local JSON = require "cjson"

local file = io.open("./shared/bin/lua/test/shared.lua", "r")
assert(file)
local contents = file:read("*a")
file:close()

local fixedJson = "local cjson_name = \"cjson\" \r\nlocal cjson = cjson or require(cjson_name)\r\ncjson.decode_array_with_array_mt(true)\r\nlocal function json_clear_null(t)\r\n  if type(t) == \"table\" then\r\n    for k,v in pairs(t)do\r\n      if v == cjson.null then\r\n        t[k] = nil\r\n      end\r\n      if type(v) == \"table\" then\r\n        json_clear_null(v)\r\n      end\r\n    end\r\n  end\r\n  return t\r\nend\r\n\r\nlocal function json_decode(str)\r\n  return json_clear_null(cjson.decode(str))\r\nend\r\n\r\nlocal parseJson\r\nparseJson = function (table)\r\n  local result\r\n  --array\r\n  if(getmetatable(table)==cjson.array_mt) then\r\nresult = _hx_tab_array({}, 0);\r\n    for k, v in ipairs(table) do\r\n      if(type(v) == \"table\") then\r\n        result:push(parseJson(v))\r\n   else\n        result:push(v) \r\n   end\r\n    end\r\n  else\r\n    result = {}\r\n    for k, v in pairs(table) do\r\n      if(type(v) == \"table\") then\r\n        result[k] = parseJson(v)\r\n      else\r\n        result[k] = v\r\n      end\r\n    end\r\n  end\r\n  return result\r\nend\n__haxe_format_JsonParser.prototype.doParse = function(self)\r\n  return parseJson(json_decode(self.str))\r\nend\r\n"

contents = string.gsub(contents, "__lua_lib_lrexlib_Rex%s=%s_G%.require%(\"rex_pcre\"%)", "__lua_lib_lrexlib_Rex = nil", 1)
local indexof = string.find(contents,"__haxe_format_JsonParser.prototype.doParse%s=")
contents = string.sub(contents,1,indexof-1) .. fixedJson .. string.sub(contents,indexof + 552)

local fixedJson2 = "__haxe_Json.parseFast = function(text) \r\n  do return __haxe_format_JsonParser.new(text):doParse() end;\r\nend\n"

local indexof = string.find(contents,"__haxe_Json.parse = function")
contents = string.sub(contents,1,indexof-1) .. fixedJson2 .. string.sub(contents,indexof)

file = io.open("./shared/bin/lua/test/shared.lua", "w")
assert(file)
file:write(contents)
file:close()
return true
