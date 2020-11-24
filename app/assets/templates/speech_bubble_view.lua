local COMMON = require "libs.common"
local RichtextLbl = require "libs_project.gui.richtext_lbl"

---@class SpeechBubbleView
local SpeechBubbleView = COMMON.class("SpeechBubbleView")

function SpeechBubbleView:initialize(nodes, config)
    self.nodes = assert(nodes)
    self.config = assert(config)
    self.rich_text = nil
    self:bind_vh()

    self:gui_check_direction()
end

function SpeechBubbleView:gui_check_direction()
    local scale = gui.get_scale(self.vh.bubble)
    local dy = 80
    local dx = 90
    local size = gui.get_size(self.vh.bubble)
    local pos = vmath.vector3(size.x / 2 - dx, size.y / 2, 0)
    local text_pos = vmath.vector3(0, 35.5, 0)
    pprint(self.config)

    if (self.config.left) then
        scale.x = -1
        pos.x = -pos.x
        text_pos.x = -text_pos.x
    end

    if (self.config.top) then
        scale.y = -1
        pos.y = -pos.y
        text_pos.y = -text_pos.y
    end

    gui.set_scale(self.vh.bubble, scale)
    gui.set_position(self.vh.bubble_origin, pos)
    gui.set_position(self.vh.text_root, text_pos)
end

---@return SpeechBubbleView
function SpeechBubbleView.create(config)
    config = config or {}
    local root = gui.get_node("speech_bubble/root")
    local nodes = gui.clone_tree(root)
    return SpeechBubbleView({
        root = nodes[COMMON.HASHES.hash("speech_bubble/root")],
        bubble = nodes[COMMON.HASHES.hash("speech_bubble/bubble")],
        text_root = nodes[COMMON.HASHES.hash("speech_bubble/text_root")],
        bubble_origin = nodes[COMMON.HASHES.hash("speech_bubble/bubble_origin")]
    }, config)
end

function SpeechBubbleView:position_set(position)
    gui.set_position(self.vh.root, position)
end

function SpeechBubbleView:text_set(text)
    self.views.lbl:set_text(text)
end

function SpeechBubbleView:bind_vh()
    self.vh = {
        root = assert(self.nodes.root),
        bubble = assert(self.nodes.bubble),
        text_root = assert(self.nodes.text_root),
        bubble_origin = assert(self.nodes.bubble_origin)
    }
    self.views = {
        lbl = RichtextLbl()
    }
    self.views.lbl.center_v = true
    self.views.lbl:set_parent(self.vh.text_root)
end

function SpeechBubbleView:update()

end

function SpeechBubbleView:show()
    gui.set_enabled(self.vh.root, true)
end

function SpeechBubbleView:hide()

end

function SpeechBubbleView:dispose()
    assert(self.vh)
    self.views.lbl:clear()
    gui.delete_node(self.vh.root)
    self.vh = nil
end

return SpeechBubbleView