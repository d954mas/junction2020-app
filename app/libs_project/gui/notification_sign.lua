local COMMON = require "libs.common"

local Btn = COMMON.class("NotificationSign")

function Btn:initialize(root_name, path)
	self.vh = {
		root = gui.get_node(root_name .. (path or "/root")),
	}
	self.root_name = root_name .. (path or "/root")
	gui.animate(self.vh.root,"scale",vmath.vector3(1.2),gui.EASING_LINEAR,1.5,0,nil,gui.PLAYBACK_LOOP_PINGPONG)
end


function Btn:set_enabled(enable)
	gui.set_enabled(self.vh.root, enable)
end


return Btn