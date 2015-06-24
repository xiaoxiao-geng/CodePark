--[[
	消息处理器

	消息处理的构思是，采用msg-handler键值对的方式，方便的设置一组全局的消息监听器
	无论代码在什么地方，都可以采用同样的监听机制进行监听

	生命周期
	setMsgListeners：设置消息监听器，格式为 {{msg1, handler1}, {msg2, handler2}}
	startProcMsg：开始处理消息，调用此函数后才开始接收消息
	stopProcMsg：停止处理消息，调用此函数后将不会接收消息

	特别注意：
	MsgHandler的监听机制采用cc.EventListenerCustom
	一旦调用startProcMsg后
	需要手动调用stopProcMsg停止监听
	否则监听器将会“永远”运行下去

	消息处理器的两种用法
	1. 继承法：继承MsgHandler类，即可将自身视为MsgHandler的一部分
	local SubClass = class("SubClass", superClass, MsgHandler)
	继承MsgHandler后，在SubClass的方法中就可以使用诸如 self:startProcMsg() 的方法了

	2. 独立对象：通过MsgHandler:create创建自定义的hander
	local handler = ul.MsgHandler:create()
	handler:setMsgListeners{...}
	...
]]
local MsgHandler = class("MsgHandler")

--- 开始处理Msg
function MsgHandler:startProcMsg()
    local conf = self._listenerConf
    -- 没有监听器配置，可以理解为不需要监听器
    if not conf then return end

    local listeners = self._msgListeners

    -- 已经有监听器了，不需要重复添加
    if listeners then return end

    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    listeners = {}

    local v
    local msg, handler, listener
    for i = 1, #conf do
        v = conf[i]
        msg, handler = v[1], v[2]

        listener = cc.EventListenerCustom:create(msg, handler)
        dispatcher:addEventListenerWithFixedPriority(listener, 1)
        listeners[#listeners + 1] = listener
    end

    self._msgListeners = listeners
end

--- 停止处理Msg
function MsgHandler:stopProcMsg()
    local listeners = self._msgListeners

    -- 当前没有监听器，不需要停止
    if not listeners then return end

    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    for i = 1, #listeners do
        dispatcher:removeEventListener(listeners[i])
    end

    self._msgListeners = nil
end

--- 设置msg监听器
-- @param listenerConf { { msgName, msgHandler }, { msgName, msgHandler } }
function MsgHandler:setMsgListeners(listenerConf)
    self._listenerConf = listenerConf
end

return MsgHandler