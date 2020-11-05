local COMMON = require "libs.common"
local Script = COMMON.new_n28s()

function Script:init(go_self)
    self.url = assert(self.go_self.gui_follow_go_url, "url can't be nil")
end

function Script:update(go_self, dt)
    self:update_position()
end

function Script:update_position()
    local position = go.get_world_position()
    msg.post(self.url, COMMON.HASHES.MSG_GUI_UPDATE_GO_POS, { position = position })
end

return Script