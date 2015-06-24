-- 状态机+事件回调方式工作
-- 上层调用应每帧调用update()
-- 上层应用应该为每个socket对象，提供事件回调函数例如 sampleEventsCallback
--[[
function M:sampleEventsCallback(ev_id,...)
	if ev_id == M.EV_CLOSED  then

	elseif ev_id == M.EV_DISCONNECTED  then

	elseif ev_id == M.EV_DATAARRIVED  then

	elseif ev_id == M.EV_CONNECTED  then

	elseif ev_id == M.EV_CONNECTFAIL  then

	elseif ev_id == M.EV_KEEPALIVE  then

	end
end


]]

local socket = require "socket"

-- class
local M = class("Scoket")

-- 状态定义
M.STATE_IDLE		= 1
M.STATE_TRYCONNECT	= 2
M.STATE_CONNECTING	= 3
M.STATE_WORKING		= 4
-- 事件定义
M.EV_CLOSED			= 1
M.EV_DISCONNECTED	= 2
M.EV_DATAARRIVED	= 3
M.EV_CONNECTED		= 4
M.EV_CONNECTFAIL	= 5
M.EV_KEEPALIVE		= 6
M.EV_TIMEDOUT		= 7


M.MAX_RECEIVE_BYTES	= 4096

M.TIMEOUT_DEFAULT	= 60
M.HEARTBEAT_DEFAULT	= 30

M.bEnableDebugMsg	= false
M.bEnableDumpSend	= false
M.bEnableDumpPack	= false

M.DEFAULT_SOCKET_NAME = "SOCKET_DEFAULT"

-- socket 连接池， 用于存放多个socket连接对象
M.sockets = {}








----- 类函数 -----
-- 创建一个socket连接对象（仅仅是创建对象，不进行连接）
function M.createSocket(name)
	name = name or M.DEFAULT_SOCKET_NAME
	local socket = M.sockets[name]
	if not socket then
		socket = M:create(name)
		M.sockets[name] = socket
	end
	return socket
end

-- 获取指定名字的连接句柄
function M.get(name)
	return M.createSocket(name)
end

-- 修改所有连接的状态
function M.enableAll(flag)
	for k, socket in pairs(M.sockets) do
		socket:setEnabled(flag)
	end
end

function M.updateSockets()
	for k, socket in pairs(M.sockets) do
		socket:update()
	end
end





-- 临时方法
local function _dumpbuffer(s)
    if(s == nil) then
        return nil
    end

    local idx = 0
    local count = 0
    local result = {}
    local table_insert = table.insert
    local string_sub = string.sub
    local string_format = string.format
    for idx = 1,#s do

        table_insert(result,string_format("%02X ",string.byte(string_sub(s,idx,idx+1))))

        count = count + 1
        if count == 8 then
            table_insert(result,"   ")
        elseif count ==16 then
            table_insert(result,"\n")
            count = 0
        end
    end
    if count>0 then
        table_insert(result,"\n")
    end
    s = table.concat(result)
    return s
end










-- 连接对象初始化
function M:ctor(name)
	self.name				= name or M.DEFAULT_SOCKET_NAME
	self.timeout			= M.TIMEOUT_DEFAULT
	self.heartbeat			= M.HEARTBEAT_DEFAULT
	self.host				= nil
	self.port				= nil
	self.readFD				= {}
	self.writeFD			= {}
	self.sendBuffer			= {}
	self.recvBuffer			= {}
	self.lastActiveTime		= 0
	self.lastKeepLiveTime	= 0
	self.receiveStatus		= nil
	self.hSocket			= nil
	self.enabled			= true
	-- self.packer			= nil
	self.state				= M.STATE_IDLE
	self.stateFuncs			= {
		[M.STATE_IDLE]			= M.updateIdle,
		[M.STATE_TRYCONNECT]	= M.updateTryConnect,
		[M.STATE_CONNECTING]	= M.updateConnecting,
		[M.STATE_WORKING]		= M.updateWorking,
	}
	self.callback =  nil
end

function M:setEventsCallback(func)
	self.callback = func
end

function M:onEvent(ev_id,...)
	local cb = self.callback
	if cb then
		cb(self, ev_id, ...)
	end
end

function M:setAddress(host, port)
	self.host = host
	self.port = port
end

function M:setEnabled(enable)
	self.enabled = enable
end

function M:setTimeout(sec)
	self.timeout = sec
end

function M:setHeartbeat(sec)
	self.heartbeat = sec
end

function M:beginConnect()
	self:close(false)
	self:setState(M.STATE_TRYCONNECT)
end

-- 向发送队列添加待发送数据
function M:sendAsync(data)
	if self.state == M.STATE_WORKING then
		table.insert(self.sendBuffer, data)
	else
		if not self.hSocket then
			print(string.format("Socket '%s':%s",self.name,"sendAsync(),socket is nil when send data!"))
			print(debug.traceback())
		end
		if not self.sendBuffer then
			print(string.format("Socket '%s':%s",self.name,"sendAsync(),send buffer is nil when send data!"))
			print(debug.traceback())
		end
		print(string.format("Socket '%s':%s",self.name,"sendAsync(),SendAsync with self.state ~= M.STATE_WORKING"))
		print(debug.traceback())
	end
end

function M:send(data)
	self:sendAsync(data)
end


-- 真正发送数据
-- 如果发送错误，则返回 -1,否则返回值>=0
function M:flush()
	if self.hSocket == nil then
		print(self.name,"Socket: flush error, self.hSocket == nil !")
		return -1
	end

	if self.state ~= M.STATE_WORKING then
		print(self.name,"Socket: flush error, state is not STATE_WORKING!")
		return -1
	end

	local sendBuffer = self.sendBuffer
	if not sendBuffer or #sendBuffer <= 0 then
		return 0
	end

	-- 将整个队列中的数据拼接到一起
	local wholebuffer = table.concat(sendBuffer)

	if string.len(wholebuffer) <= 0 then
		return 0
	end

	if M.bEnableDumpSend then
		print('Socket send:\n'.. _dumpbuffer(wholebuffer))
	end

	-- 发送
	local sent, err = self.hSocket:send( wholebuffer )

	if not sent then
		return -1
	else
		self.lastActiveTime = os.time()
	end

	-- 抽取尚未发送成功的数据，重新丢回到发送队列中
	wholebuffer = string.sub(wholebuffer, sent + 1)
	self.sendBuffer = {}
	if wholebuffer then 
		if string.len(wholebuffer) > 0 then
			table.insert(self.sendBuffer, wholebuffer)
		end
	end
	return sent
end


function M:update()
	if not self.enabled then
		return
	end

	local updateFunc = self.stateFuncs[self.state]
	if updateFunc then
		updateFunc(self)
	else
		print("Socket: unkown state:", self.state)
	end
end

function M:updateIdle()

end

function M:updateTryConnect()
	local hSocket = socket.tcp()
	hSocket:setoption("tcp-nodelay", true)
	hSocket:setoption("linger", { on = false, timeout = 0 } )
	hSocket:settimeout(0)
	hSocket:connect(self.host,self.port)

	table.insert(self.readFD, hSocket)
	table.insert(self.writeFD, hSocket)

	self.hSocket = hSocket
	self:setState(M.STATE_CONNECTING)
	self.lastActiveTime = os.time()
end

function M:updateConnecting()
	local _, _, err = socket.select(nil, self.writeFD, 0)
	local shouldClose = false
	if err == nil then	-- 正常的状态
		self:setState(M.STATE_WORKING)
		self:onEvent(M.EV_CONNECTED)
		return

	elseif err == "timeout" then
		if (self.lastActiveTime >= 0) then
			local timeUsed = os.time() - self.lastActiveTime
			if timeUsed > self.timeout then
				shouldClose = true
				if M.bEnableDebugMsg  then
					print(self.name,string.format('Socket: timeout! hSocket: %s, timeUsed: %d',tostring(self.hSocket), timeUsed))
				end		
			end			
		end
	end

	if shouldClose then
		self:close(false)
		self:onEvent(M.EV_CONNECTFAIL,err)
	end
end

function M:updateWorking()
	local rt, _, err = socket.select(self.readFD, nil, 0)
	local shouldUpdateTimeout = true
	local shouldClose = false

	if err == nil then 
		_, shouldClose = self:receive()
	elseif err == "timeout" then
		--DO NOTHING
	else
		print("socket select read error!", err)
		shouldClose = true
	end

	if shouldClose then
		self:onEvent(M.EV_DISCONNECTED)
		self:close(false)
		return
	end

	if self.state == M.STATE_WORKING then
		-- TODO 检查心跳时间检测的代码
		if os.time() - self.lastKeepLiveTime > self.heartbeat then
			self:onEvent(M.EV_KEEPALIVE)
			self.lastKeepLiveTime = os.time()
		end

		if (self.lastActiveTime >= 0) then
			local timeUsed = os.time() - self.lastActiveTime
			if timeUsed > self.timeout then
				shouldClose = true
				if M.bEnableDebugMsg then
					print(self.name,string.format('socket timeout %s %d',tostring(self.hSocket), timeUsed))
				end		
			end			
		end
	end

	if shouldClose == false then
		local sent = self:flush()
		if sent == -1 then
			shouldClose = true
		end
	end
	 
	if shouldClose then
		self:close(false)
		self:onEvent(M.EV_DISCONNECTED,"send error")
	end
end


function M:close(bReserveState)
	local hSocket = self.hSocket
	if hSocket then
		if M.bEnableDebugMsg then
			print(self.name,string.format('Socket: close socket: %s',tostring(hSocket)))
		end	
		hSocket:shutdown()
		hSocket:close()
		table.removebyvalue(self.readFD,  hSocket)
		table.removebyvalue(self.writeFD, hSocket)
	end

	self.hSocket = nil
	self.sendBuffer = {}
	self.recvBuffer = {}
	self.lastActiveTime = 0

	if not bReserveState then
		self:setState(M.STATE_IDLE)
	end
end

function M:receive()
	local s, status,rest
	local hSocket		= self.hSocket
	local receiveFinish	= false
	local totalReceived	= 0
	local recvBuffer	= self.recvBuffer
	local name			= self.name
	
	-- 接收完所有数据
	repeat
		s, status, rest = hSocket:receive(M.MAX_RECEIVE_BYTES)
		if (rest ~= nil ) then
			s = rest
		end
		if s ~= nil and s ~= "" then
			totalReceived = totalReceived + #s
			table.insert(recvBuffer, s)
			self.lastActiveTime = os.time()
		else
			receiveFinish = true
		end
		receiveFinish = true
	until(receiveFinish)

	if #recvBuffer> 0 then
		if M.bEnableDumpPack then
			print('Socket receive:['..name..']\n'.. _dumpbuffer(table.concat(recvBuffer)))
		end
		self:onEvent(M.EV_DATAARRIVED)
	end


	local shouldClose = false
	if status == "closed" or status == "Socket is not connected" then
		shouldClose = true
	end
	
	self.receiveStatus = status
	return totalReceived, shouldClose

end

function M:setState(state)
	self.state = state
end

function M:onTimeout()

end

return M