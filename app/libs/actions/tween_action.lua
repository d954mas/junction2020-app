local COMMON = require "libs.common"
local BaseAction = require "libs.actions.action"
local TWEEN = require "libs.tween"

local OBJECT_TYPES = {
    TABLE = "TABLE",
    GO = "GO",
    GUI = "GUI"
}

---@class InterpolatedAction:Action
local Action = COMMON.class("TweenAction", BaseAction)
Action.__use_vector3 = false
Action.__use_vector4 = false
Action.__use_quaternion = false
Action.__use_current_context = true

function Action:config_check()
    assert(self.config.object)
    assert(self.config.property)
    assert(self.config.time)

    self.object_type = assert(self:object_get_type(), "unknown type for object:" .. tostring(self.config.object))
    self.config.from = self.config.from and self:config_value_to_table(self.config.from) or self:config_get_from()
    assert(type(self.config.from) == "table", "from must be table was:" .. type(self.config.from))
    self.config.to = self.config.to and self:config_value_to_table(self.config.to) or self:config_get_to()
    assert(type(self.config.to) == "table", "to must be table was:" .. type(self.config.to))

    for k, v in pairs(self.config.to) do
        assert(self.config.from[k], "no from value for key:" .. tostring(k))
    end
end

function Action:object_get_type()
    if type(self.config.object) == "table" then
        return OBJECT_TYPES.TABLE
    elseif type(self.config.object) == "userdata" and pcall(gui.get_height) then
        return OBJECT_TYPES.GUI
    elseif type(self.config.object) == "userdata" and go then
        return OBJECT_TYPES.GO
    end
end

function Action:initialize(config)
    self.__use_vector3 = config.v3
    self.__use_vector4 = config.v4
    self.__use_quaternion = config.quaternion
    BaseAction.initialize(self, config)
    self.OBJECT_TYPES = OBJECT_TYPES

    self.tween_value = COMMON.LUME.clone_deep(self.config.from)
    self.tween = TWEEN.new(self.config.time, self.tween_value, self.config.to, self.config.easing)
    self.tween.initial = self.from
end

--region get initial value
function Action:config_get_from()
    local data
    if self.object_type == OBJECT_TYPES.TABLE then
        data = self:config_get_parameter_from_table()
    elseif self.object_type == OBJECT_TYPES.GO then
        data = self:config_get_parameter_from_go()
    elseif self.object_type == OBJECT_TYPES.GUI then
        data = self:config_get_parameter_from_gui()
    end
    return self:config_value_to_table(data)
end

function Action:config_get_to()
    if self.config.by then
        local to = self:config_value_to_table(self.config.by)
        for k, v in pairs(to) do
            to[k] = v + self.config.from[k]
        end
    end
end

function Action:config_value_to_table(data)
    assert(data)
    local type_data = type(data)
    if type_data == "number" then
        return { data }
    elseif type_data == "table" then
        return data
    elseif type_data == "userdata" then
        if self.__use_vector3 then
            self.__use_vector3 = vmath.vector3(data)
            return { x = data.x, y = data.y, z = data.z }
        elseif self.__use_vector4 then
            self.__use_vector4 = vmath.vector4(data)
            return { x = data.x, y = data.y, z = data.z, w = data.w }
        elseif self.__use_quaternion then
            self.__use_quaternion = vmath.quat(data)
            return { x = data.x, y = data.y, z = data.z, w = data.w }
        end
        error("unknown userdata")
    end
    error("unknown type:" .. type_data)
end

function Action:config_table_to_value(data)
    if self.__use_vector3 then
        self.__use_vector3.x = self.tween_value.x
        self.__use_vector3.y = self.tween_value.y
        self.__use_vector3.z = self.tween_value.z
        return self.__use_vector3
    elseif self.__use_vector4 then
        self.__use_vector4.x = self.tween_value.x
        self.__use_vector4.y = self.tween_value.y
        self.__use_vector4.z = self.tween_value.z
        self.__use_vector4.w = self.tween_value.w
        return self.__use_vector4
    elseif self.__use_quaternion then
        self.__use_quaternion.x = self.tween_value.x
        self.__use_quaternion.y = self.tween_value.y
        self.__use_quaternion.z = self.tween_value.z
        self.__use_quaternion.w = self.tween_value.w
        return self.__use_quaternion
    end

    if data[1] then
        return data[1]
    end
    return data[self.config.property]

end

function Action:config_get_parameter_from_table()
    return assert(self.config.object[self.config.property], "no property in table:" .. self.config.property)
end
function Action:config_get_parameter_from_go()
    return go.get(self.config.object, self.config.property)
end

function Action:config_get_parameter_from_gui()
    local f = self.config_get_from_f
    if not f then
        local name = "get_" .. self.config.property
        f = gui[name]
        assert(f, "no property in gui:" .. name)
        self.config_get_from_f = f
    end

    return self:config_value_to_table(f(self.config.object))
end
--endregion

--region set_value
function Action:set_property()
    if self.object_type == OBJECT_TYPES.TABLE then
        self:set_property_table()
    elseif self.object_type == OBJECT_TYPES.GUI then
        self:set_property_gui()
    elseif self.object_type == OBJECT_TYPES.GO then
        pcall(self.set_property_go,self)
    end
end

function Action:set_property_table()
    self.config.object[self.config.property] = self:config_table_to_value(self.tween_value)
end
function Action:set_property_go()
    return go.set(self.config.object, self.config.property, self:config_table_to_value(self.tween_value))
end

--region set_value
function Action:set_property_gui()
    local f = self.set_property_f
    if not f then
        local name = "set_" .. self.config.property
        f = gui[name]
        assert(f, "can't set property in gui:" .. name)
    end
    return f(self.config.object, self:config_table_to_value(self.tween_value))
end


function Action:act(dt)
    if self.config.delay then
        COMMON.coroutine_wait(self.config.delay)
    end
    self.tween_working = true
    while (self.tween_working) do
        self.tween_working = not self.tween:update(dt)
        self:set_property()
        dt = coroutine.yield()
    end
end

return Action