--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local Widget = ccui.Widget

function Widget:onTouch(callback)
    self:addTouchEventListener(function(sender, state)
        local event = {x = 0, y = 0}
        if state == 0 then
            event.name = "began"
        elseif state == 1 then
            event.name = "moved"
        elseif state == 2 then
            event.name = "ended"
        else
            event.name = "cancelled"
        end
        event.target = sender
        if callback then
            callback(event)
        else
            print("*****do not set onTouch callback*****")
        end
    end)
    return self
end

function Widget.setSoundPlayHandler(value)
    Widget._soundPlayHandler = value
end

local function _doDownAction(node, sx, sy)
    node:stopAllActions()
    node:runAction(
        cc.EaseIn:create(cc.ScaleTo:create(0.1, 1.15 * sx, 1.15 * sy), 2)
        )
end

local function _doUpAction(node, sx, sy)
    node:stopAllActions()
    node:runAction(
        cc.Sequence:create(
            cc.EaseIn:create(cc.ScaleTo:create(0.1, 0.9 * sx, 0.9 * sy), 2),
            cc.ScaleTo:create(0.075, 1.05 * sx, 1.05 * sy),
            cc.ScaleTo:create(0.03, 1 * sx, 1 * sy)
            )
        )
end

local function _doCancelAction(node, sx, sy)
    node:stopAllActions()
    node:runAction(
        cc.Sequence:create(
            cc.EaseQuadraticActionInOut:create(cc.ScaleTo:create(0.15, 0.95 * sx, 0.95 * sy)),
            cc.EaseOut:create(cc.ScaleTo:create(0.1, 1 * sx, 1 * sy), 2)
            )
        )
end

function Widget:onTouchWithAction(callback)
    local sx = self:getScaleX()
    local sy = self:getScaleY()

    if self.setPressedActionEnabled then
        self:setPressedActionEnabled(false)
    end

    -- self.__origin_scale_x = sx
    -- self.__origin_scale_y = sy

    local _touchHandler = function(e)
        local node = e.target

        if e.name == "began" then
            node.__bFocus = true
            _doDownAction(node, sx, sy)

            -- 调用播放声音回调
            if Widget._soundPlayHandler then
                Widget._soundPlayHandler(node)
            end

        elseif e.name == "moved" then

            if node.__bFocus then
                -- 检测是否离开范围
                if not node:hitTest(node:getTouchMovePosition()) then
                    node.__bFocus = false
                    _doCancelAction(node, sx, sy)
                end
            else
                -- 检测是否在范围内
                if node:hitTest(node:getTouchMovePosition()) then
                    node.__bFocus = true
                    _doDownAction(node, sx, sy)
                end
            end


        elseif e.name == "ended" or e.name == "cancelled" then
            if node.__bFocus then
                node.__bFocus = false
                _doUpAction(node, sx, sy)
            end
        end

        callback(e)
    end

    self:onTouch(_touchHandler)

    return self
end