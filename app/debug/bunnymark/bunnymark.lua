local M = {}


local bunnies = {}
local frames = {}

local TEXT = "Bunnies: %d FPS: %.2f. Click to add more."

local BUNNY_IMAGES = {
	hash("rabbitv3_batman"),
	hash("rabbitv3_bb8"),
	hash("rabbitv3"),
	hash("rabbitv3_ash"),
	hash("rabbitv3_frankenstein"),
	hash("rabbitv3_neo"),
	hash("rabbitv3_sonic"),
	hash("rabbitv3_spidey"),
	hash("rabbitv3_stormtrooper"),
	hash("rabbitv3_superman"),
	hash("rabbitv3_tron"),
	hash("rabbitv3_wolverine"),
}

function M.start()
	M.bunnies = {}
	frames = {}
end

function M.stop()
	-- do nothing, bunnies will get deleted with the collection when it is unloaded
end

function M.random_image()
	return BUNNY_IMAGES[math.random(1, #BUNNY_IMAGES)]
end

function M.create_bunny()
	local id = factory.create("#factory")
	local bunny = nil
	if id then
		msg.post(msg.url(nil, id, "sprite"), "play_animation", { id = M.random_image() })
		-- we use msg.url() inside the engine, if you need maximum speed
		-- it's better to pre-cache URLs 
		bunny = { id = msg.url(nil, id, nil) }
		M.bunnies[#M.bunnies + 1] = bunny
	end
	return bunny
end

function M.create_gui_bunny()
	local box = gui.new_box_node(vmath.vector3(), vmath.vector3())
	local bunny = nil
	if box then
		gui.set_size_mode(box, gui.SIZE_MODE_AUTO)
		gui.set_texture(box, "bunnymark")
		gui.play_flipbook(box, M.random_image())
		bunny = { node = box }
		M.bunnies[#M.bunnies + 1] = bunny
	end
	return bunny
end

function M.update()
	table.insert(frames, socket.gettime())
end

function M.get_bunny_count()
	return #M.bunnies
end

function M.get_fps()
	local fps = 0
	if #frames == 61 then
		table.remove(frames, 1)
		fps = 1 / ((frames[#frames] - frames[1]) / (#frames - 1))
	end
	return fps
end

return M
