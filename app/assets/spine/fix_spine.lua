local requiref =require
local lfs = requiref "lfs"
local cjson = requiref "cjson"

function get_file_name(url)
  return url:match("^.+/(.+)$")
end

function get_file_extension(url)
  return url:match("^.+(%..+)$")
end

function write_file(path, content)
    local file = io.open(path, "w") -- r read mode and b binary mode
    if not file then return nil end
    file:write(content)
	file:flush()
	file:close()
end

function read_file(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end


function attrdir (path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                attrdir (f)
            else
				local ext = get_file_extension(file)
				if ext == ".json" then
					print("check:" .. f)
					local str = read_file(f)
					str = string.gsub(str, "\"spine\":\"3%.8%.86\"", "\"spine\":\"3.7.94\"", 1)
					str = string.gsub(str, "\"transform\":\"noScale\"", "\"inheritScale\": false")
					str = string.gsub(str, "\"skins\":%[{\"name\":\"default\",\"attachments\":{","\"skins\":{\"default\":{")
					str = string.gsub(str, "\"skins\":%[{\"name\":\"base\",\"attachments\":{","\"skins\":{\"base\":{")
						str = string.gsub(str, "{\"name\":\"base\",\"attachments\":{","\"base\":{")
					str = string.gsub(str, "}}}},\"base\":{","}}},\"base\":{")
					str = string.gsub(str, "{\"name\":\"elite\",\"attachments\":{","\"elite\":{")
					str = string.gsub(str, "}}}},\"elite\":{","}}},\"elite\":{")
					str = string.gsub(str, "{\"name\":\"boss\",\"attachments\":{","\"boss\":{")
					str = string.gsub(str, "}}}},\"boss\":{","}}},\"boss\":{")
					str = string.gsub(str, "}}}}%]","}}}}")
					write_file(f,str)
					--local data = cjson.decode(str)
					
				end
            end
        end
    end
end

attrdir (".")