local COMMON = require "libs.common"
local Script = COMMON.new_n28s()

function Script:init()
    self.msg_receiver = COMMON.MSG()
    self.msg_receiver:add(COMMON.HASHES.MSG_GUI_UPDATE_GO_POS, self.update_position)
end

function Script:get_root_node()
    return gui.get_node("root")
end

function Script:update_position(message_id, message, sender)
    self.root_node = self:get_root_node();
    self.root_node_position = assert(message.position)
    if (self.root_node) then
        gui.set_position(self.root_node, self.root_node_position)
    end
end

function Script:on_message(message_id, message, sender)
    self.msg_receiver:on_message(self, message_id, message, sender)
end

return Script