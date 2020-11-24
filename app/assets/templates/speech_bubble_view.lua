local COMMON = require "libs.common"
local RichtextLbl = require "libs_project.gui.richtext_lbl"

---@class SpeechBubbleView
local SpeechBubbleView = COMMON.class("SpeechBubbleView")

function SpeechBubbleView:initialize(nodes)
    self.nodes = assert(nodes)
    self.rich_text = nil
    self:bind_vh()
end

---@return SpeechBubbleView
function SpeechBubbleView.create()
    local root = gui.get_node("speech_bubble/root")
    local nodes = gui.clone_tree(root)
    return SpeechBubbleView({
        root = nodes[COMMON.HASHES.hash("speech_bubble/root")],
        bubble = nodes[COMMON.HASHES.hash("speech_bubble/bubble")],
        text_root = nodes[COMMON.HASHES.hash("speech_bubble/text_root")]
    })
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
        text_root = assert(self.nodes.text_root)
    }
    self.views = {
        lbl = RichtextLbl()
    }
    self.views.lbl:set_parent(self.vh.text_root)
end

function SpeechBubbleView:update()

end

function SpeechBubbleView:show()
    gui.set_enabled(self.vh.root,true)
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