local COMMON = require "libs.common"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"
local TickLabel = require "libs_project.gui.tick_label"

---@class ManaPanelView
local View = COMMON.class("ManaPanelView")

---@param world World
function View:initialize(root_name, world)
    self.root_name = assert(root_name)
    self.world = assert(world)
    self.value = 0
    self:bind_vh()
    self:set_value(self.value, true)
end

function View:set_value(value, force)
    self.views.label:set_value(value, force)
end

function View:value_add(value, tag)
    self.value = self.value + value
    self:set_value(self.value)
end

function View:on_storage_changed()

end

function View:update(dt)
    self.views.label:update(dt)
end

function View:bind_vh()
    self.views = {
        ---@type Ticklabel
        label = TickLabel(gui.get_node(self.root_name .. "/lbl"))
    }
end

return View