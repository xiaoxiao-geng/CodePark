--------------------------------------------------------------------------------
-- This class inherits the MOAILayer. <br>
-- Simplifies the generation of a set of size and layer. <br>
--------------------------------------------------------------------------------

-- import
local table                 = require "hp/lang/table"
local class                 = require "hp/lang/class"
local Event                 = require "hp/event/Event"
local InputManager          = require "hp/manager/InputManager"

-- class define
local M                     = class()

-- event cache
local EVENT_TOUCH_DOWN      = Event(Event.TOUCH_DOWN)
local EVENT_TOUCH_UP        = Event(Event.TOUCH_UP)
local EVENT_TOUCH_MOVE      = Event(Event.TOUCH_MOVE)
local EVENT_TOUCH_CANCEL    = Event(Event.TOUCH_CANCEL)

--
local function getPointByCache(self, e)
    for i, p in ipairs(self._touchPoints) do
        if p.idx == e.idx then
            return p
        end
    end
end

-- 
local function getPointByEvent(self, e)
    local layer = self._touchLayer

    local p = getPointByCache(self, e) or {}
    p.idx = e.idx
    p.tapCount = e.tapCount
    p.oldX, p.oldY = p.x, p.y
    p.x, p.y = layer:wndToWorld(e.x, e.y, 0)
    p.screenX, p.screenY = e.x, e.y

    --------------------------------------------------------------------------------
    -- 2013-9-15 ultralisk fix begin
    -- 将stoped字段正确赋值到p中
    -- 从cache中取出的p，没有设置stoped属性
    -- 导致InputManager中注册的事件有可能无法被监听到
    -- 如果cache中取出的p是stoped == true，则无论这个事件是否被拦截，在通过TouchProcesser后都会被拦截
    --------------------------------------------------------------------------------
    p.stoped = e.stoped
    --------------------------------------------------------------------------------
    -- 2013-9-15 ultralisk fix end
    --------------------------------------------------------------------------------

    
    if p.oldX and p.oldY then
        p.moveX = p.x - p.oldX
        p.moveY = p.y - p.oldY
    else
        p.oldX, p.oldY = p.x, p.y
        p.moveX, p.moveY = 0, 0
    end
    
    return p
end

local function eventHandle(self, e, o)
    --------------------------------------------------------------------------------
    -- 2013-9-15 ultralisk change begin
    -- 如果事件链中有一环为stop，则在事件链末尾标记为stoped
    --------------------------------------------------------------------------------
    local stoped = e.stoped

    local layer = self._touchLayer
    while o do
        if o.isTouchEnabled and not o:isTouchEnabled() then
            break
        end
        if o.dispatchEvent then
            o:dispatchEvent(e)

            if e.stoped then stoped = e.stoped end
        end
        if o.getParent then
            o = o:getParent()
        else
            o = nil
        end
    end

    e.stoped = stoped
    --------------------------------------------------------------------------------
    -- 2013-9-15 ultralisk change end
    --------------------------------------------------------------------------------
end 

--------------------------------------------------------------------------------
-- 在Layer中查找触摸prop
-- 1. 排除不可见的prop
-- 2. 排除裁剪区外的prop
-- @param layer
-- @param x
-- @param y
-- @return prop or nil (if not found)
--------------------------------------------------------------------------------
local function getPropFromPoint( layer, x, y )
    local props = { layer:getPartition():propListForPoint( x, y, 0, MOAILayer.SORT_PRIORITY_DESCENDING ) }
    for k, prop in pairs( props ) do
        if prop:getVisible() and ( not prop.isInClipRect or prop:isInClipRect( x, y ) ) then return prop end
    end
    return nil
end

--------------------------------------------------------------------------------
-- The constructor.
-- @param layer (option)Parameter is set to Object.<br>
--------------------------------------------------------------------------------
function M:init(layer)
    self._touchLayer        = assert(layer)
    self._touchPoints       = {}
    self._eventSource       = nil
    self._enabled           = true
end

--------------------------------------------------------------------------------
-- イベント発生元を設定します.
-- 典型的には、Sceneインスタンスが設定されます.
--
-- 2013-9-14 ultralisk change begin
-- 添加优先级字段，用于注册触摸事件
--------------------------------------------------------------------------------
function M:setEventSource(eventSource, priority)
    if self._eventSource then
        self._eventSource:removeEventListener(Event.TOUCH_DOWN, self.touchDownHandler, self)
        self._eventSource:removeEventListener(Event.TOUCH_UP, self.touchUpHandler, self)
        self._eventSource:removeEventListener(Event.TOUCH_MOVE, self.touchMoveHandler, self)
        self._eventSource:removeEventListener(Event.TOUCH_CANCEL, self.touchCancelHandler, self)
    end
    
    self._eventSource = eventSource
    
    if self._eventSource then
        self._eventSource:addEventListener(Event.TOUCH_DOWN, self.touchDownHandler, self, priority)
        self._eventSource:addEventListener(Event.TOUCH_UP, self.touchUpHandler, self, priority)
        self._eventSource:addEventListener(Event.TOUCH_MOVE, self.touchMoveHandler, self, priority)
        self._eventSource:addEventListener(Event.TOUCH_CANCEL, self.touchCancelHandler, self, priority)
    end
end

--------------------------------------------------------------------------------
-- 2013-9-14 ultralisk change end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- イベントソースに対する参照を削除します.
--------------------------------------------------------------------------------
function M:dispose()
    self:setEventSource(nil)
end

--------------------------------------------------------------------------------
-- プロセッサーが有効かどうか設定します.
--------------------------------------------------------------------------------
function M:setEnabled(value)
    self._enabled = value
end

--------------------------------------------------------------------------------
-- プロセッサーが有効かどうか返します.
--------------------------------------------------------------------------------
function M:isEnabled()
    return self._enabled
end

--------------------------------------------------------------------------------
-- タッチした時のイベント処理を行います.
--------------------------------------------------------------------------------
function M:touchDownHandler(e)
    if not self:isEnabled() then
        return
    end
    
    local layer = self._touchLayer

    local p = getPointByEvent(self, e)
    p.touchingProp = getPropFromPoint( layer, p.x, p.y )
    table.insertElement(self._touchPoints, p)
    
    local te = table.copy(p, EVENT_TOUCH_DOWN)
    te.points = self._touchPoints

    if p.touchingProp then
        eventHandle(self, te, p.touchingProp)
    end
    if not te.stoped then
        layer:dispatchEvent(te)
    end
    if te.stoped then
        e:stop()
    end
end

----------------------------------------------------------------
-- タッチした時のイベント処理を行います.
----------------------------------------------------------------
function M:touchUpHandler(e)
    if not self:isEnabled() then
        return
    end

    local layer = self._touchLayer

    local p = getPointByEvent(self, e)
    local te = table.copy(p, EVENT_TOUCH_UP)
    
    if p.touchingProp then
        eventHandle(self, te, p.touchingProp)
    end
    
    local o = getPropFromPoint( layer, p.x, p.y )
    if o and o ~= p.touchingProp then
        eventHandle(self, te, o)
    end
    
    if not te.stoped then
        layer:dispatchEvent(te)
    end
    if te.stoped then
        e:stop()
    end
    
    table.removeElement(self._touchPoints, p)
end

----------------------------------------------------------------
-- タッチした時のイベント処理を行います.
----------------------------------------------------------------
function M:touchMoveHandler(e)
    if not self:isEnabled() then
        return
    end

    local layer = self._touchLayer

    local p = getPointByEvent(self, e)
    local te = table.copy(p, EVENT_TOUCH_MOVE)
    
    if p.touchingProp then
        eventHandle(self, te, p.touchingProp)
    end
    
    local o = getPropFromPoint( layer, p.x, p.y )
    if o and o ~= p.touchingProp then
        eventHandle(self, te, o)
    end
    
    if not te.stoped then
        layer:dispatchEvent(te)
    end
    if te.stoped then
        e:stop()
    end
end

----------------------------------------------------------------
-- タッチした時のイベント処理を行います.
----------------------------------------------------------------
function M:touchCancelHandler(e)
    if not self:isEnabled() then
        return
    end

    local layer = self._touchLayer

    local p = getPointByEvent(self, e)
    local te = table.copy(p, EVENT_TOUCH_CANCEL)
    
    if p.touchingProp then
        eventHandle(self, te, p.touchingProp)
    end
    
    local o = getPropFromPoint( layer, p.x, p.y )
    if o and o ~= p.touchingProp then
        eventHandle(self, te, o)
    end
    if not te.stoped then
        layer:dispatchEvent(te)
    end
    if te.stoped then
        e:stop()
    end
    
    table.removeElement(self._touchPoints, p)
end

return M