--------------------------------------------------------------------------------
-- The base class for all display objects. <br>
-- To inherit MOAIPropUtil, you can use the convenience function. <br>
-- To inherit EventDispatcher, you can use the event notification. <br>
-- <br>
-- Use the MOAIProp class. <br>
-- By changing the M.MOAI_CLASS, you can change to another class. <br>
-- See MOAIProp.<br>
-- Base Classes => EventDispatcher, MOAIPropUtil<br>
--------------------------------------------------------------------------------

-- import
local class                 = require "hp/lang/class"
local table                 = require "hp/lang/table"
local EventDispatcher       = require "hp/event/EventDispatcher"
local MOAIPropUtil          = require "hp/util/MOAIPropUtil"
local PropertyUtil          = require "hp/util/PropertyUtil"

-- class
local M                     = class(EventDispatcher, MOAIPropUtil)
local MOAIPropInterface     = MOAIProp.getInterfaceTable()

-- constraints
M.MOAI_CLASS                = MOAIProp
M.PRIORITY_PROPERTIES       = {
    "texture",
}

--------------------------------------------------------------------------------
-- Instance generating functions.<br>
-- Unlike an ordinary class, and based on the MOAI_CLASS.<br>
-- To inherit this function is not recommended.<br>
-- @param ... params.
-- @return instance.
--------------------------------------------------------------------------------
function M:new(...)
    local obj = self.MOAI_CLASS.new()
    table.copy(self, obj)

    EventDispatcher.init(obj)

    if obj.init then
        obj:init(...)
    end

    obj.new = nil
    obj.init = nil
    
    return obj
end

--------------------------------------------------------------------------------
-- The constructor.
--------------------------------------------------------------------------------
function M:init(...)
    self._touchEnabled = true
end

--------------------------------------------------------------------------------
-- Set the name.
-- @param name Object name.<br>
--------------------------------------------------------------------------------
function M:setName(name)
    self.name = name
end

--------------------------------------------------------------------------------
-- Returns the name.
-- @return Object name.
--------------------------------------------------------------------------------
function M:getName()
    return self.name
end

--------------------------------------------------------------------------------
-- Sets the parent.
-- @return parent object.
--------------------------------------------------------------------------------
function M:getParent()
    return self._parent
end

--------------------------------------------------------------------------------
-- Sets the parent.
-- @param parent parent
--------------------------------------------------------------------------------
function M:setParent(parent)
    if parent == self:getParent() then
        return
    end
    
    -- remove
    if self._parent and self._parent.isGroup then
        self._parent:removeChild(self)
    end
    
    -- set
    MOAIPropInterface.setParent(self, parent)
    self._parent = parent
    
    -- add
    if parent and parent.isGroup then
        parent:addChild(self)
    end

    -- 2013-9-16 ultralisk add
    -- 如果parent有裁剪框，则设置裁剪框
    if parent then
        self:setClipRect( parent._clipRect )
    else
        self:setClipRect( nil )
    end
end

--------------------------------------------------------------------------------
-- Set the parameter setter function.
-- @param params Parameter is set to Object.<br>
--------------------------------------------------------------------------------
function M:copyParams(params)
    if not params then
        return
    end

    -- copy priority properties
    local priorityParams = {}
    if self.PRIORITY_PROPERTIES then
        for i, v in ipairs(self.PRIORITY_PROPERTIES) do
            priorityParams[v] = params[v]
            params[v] = nil
        end
        PropertyUtil.setProperties(self, priorityParams, true)
    end
    
    -- priority properties
    PropertyUtil.setProperties(self, params, true)
    
    -- reset params
    if self.PRIORITY_PROPERTIES then
        for i, v in ipairs(self.PRIORITY_PROPERTIES) do
            params[v] = priorityParams[v]
        end
    end
end

--------------------------------------------------------------------------------
-- Set the MOAILayer instance.
--------------------------------------------------------------------------------
function M:setLayer(layer)
    if self.layer == layer then
        return
    end

    if self.layer then
        self.layer:removeProp(self)
    end

    self.layer = layer

    if self.layer then
        layer:insertProp(self)
    end
end

--------------------------------------------------------------------------------
-- Returns the MOAILayer.
--------------------------------------------------------------------------------
function M:getLayer()
    return self.layer
end

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------
function M:getNestLevel()
    local parent = self:getParent()
    if parent and parent.getNestLevel then
        return parent:getNestLevel() + 1
    end
    return 1
end


--------------------------------------------------------------------------------
-- Sets the touch enabled.
-- @param value touch enabled.
--------------------------------------------------------------------------------
function M:setTouchEnabled(value)
    self._touchEnabled = value
end

--------------------------------------------------------------------------------
-- Sets the touch enabled.
-- @param value touch enabled.
--------------------------------------------------------------------------------
function M:isTouchEnabled()
    return self._touchEnabled
end

--------------------------------------------------------------------------------
-- Dispose resourece.
--------------------------------------------------------------------------------
function M:dispose()
    local parent = self:getParent()
    if parent and parent.isGroup then
        parent:removeChild(self)
    end
    
    self:setLayer(nil)
end

--------------------------------------------------------------------------------
-- If the object will collide with the screen, it returns true.<br>
-- TODO:If you are rotating, it will not work.
-- @param prop MOAIProp object
-- @return If the object is a true conflict
--------------------------------------------------------------------------------
function M:hitTestObject(prop)
    local worldX, worldY = prop:getWorldLoc()
    local x, y = prop:getLoc()
    local diffX, diffY = worldX - x, worldY - y

    local left, top = MOAIPropUtil.getLeft(prop) + diffX, MOAIPropUtil.getTop(prop) + diffY
    local right, bottom = MOAIPropUtil.getRight(prop) + diffX, MOAIPropUtil.getBottom(prop) + diffY
    
    if self:inside(left, top, 0) then
        return true
    end
    if self:inside(right, top, 0) then
        return true
    end
    if self:inside(left, bottom, 0) then
        return true
    end
    if self:inside(right, bottom, 0) then
        return true
    end
    return false
end

--------------------------------------------------------------------------------
-- If the object will collide with the screen, it returns true.<br>
-- @param screenX x of screen
-- @param screenY y of screen
-- @param screenZ (option)z of screen
-- @return If the object is a true conflict
--------------------------------------------------------------------------------
function M:hitTestScreen(screenX, screenY, screenZ)
    assert(self.layer)
    
    screenZ = screenZ or 0
    
    local worldX, worldY, worldZ = self.layer:wndToWorld(screenX, screenY, screenZ)
    return self:inside(worldX, worldY, worldZ)
end

--------------------------------------------------------------------------------
-- If the object will collide with the world, it returns true.<br>
-- @param worldX world x of layer
-- @param worldY world y of layer
-- @param worldZ (option)world z of layer
-- @return If the object is a true conflict
--------------------------------------------------------------------------------
function M:hitTestWorld(worldX, worldY, worldZ)
    worldZ = worldZ or 0
    return self:inside(worldX, worldY, worldZ)
end





--------------------------------------------------------------------------------
-- 2013-9-16 ultralisk add begin
-- 添加裁剪框（clip）相关内容
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 获取当前坐标对应的外界坐标
-- 采用层层递归的方式计算最外层parent的坐标
--------------------------------------------------------------------------------
function M:getFullPos()
    if self.getParent then
        local parent = self:getParent()
        if parent and parent.getFullPos then
            local px, py = parent:getFullPos()
            local x, y = self:getPos()
            return px + x, py + y
        end
    end
    return self:getPos()
end

--------------------------------------------------------------------------------
-- 设置裁剪框
-- 警告！不要手动使用此方法
-- 请用Group:setClip添加裁剪框
-- @param rect 裁剪框数组    MoaiScissorRec
--------------------------------------------------------------------------------
function M:setClipRect( rect )
    self._clipRect = rect
    if self.getChildren then
        local children = self:getChildren()
        if children then
            for k, v in pairs( children ) do
                if v.setClipRect then v:setClipRect( rect ) end
            end
        end
    end

    self:setScissorRect( rect )
end

--------------------------------------------------------------------------------
-- 传入的点是否在控件的裁剪范围内（可见部分）
-- @param x 监测点x
-- @param y 监测点y
--------------------------------------------------------------------------------
function M:isInClipRect( x, y )
    local rect = self._clipRect
    if not rect then return true end

    local left, top = rect:getLoc()

    left = left + rect.srcX
    top = top + rect.srcY

    return x >= left and y >= top and x <= ( left + rect.width ) and y <= ( top + rect.height )
end

--------------------------------------------------------------------------------
-- 2013-9-16 ultralisk add end
--------------------------------------------------------------------------------

return M