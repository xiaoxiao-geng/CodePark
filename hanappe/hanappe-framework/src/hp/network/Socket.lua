local class					= require "hp/lang/class"
local socket 				= require "socket"
local table             	= require "hp/lang/table"
local Logger                = require "hp/util/Logger"
local string 				= require "hp/lang/string"
-- class
local M                     = class()

M.STATE_IDLE		= 1
M.STATE_TRYCONNECT	= 2
M.STATE_CONNECTING	= 3
M.STATE_WORKING		= 4

M.MAX_RECEIVE_BYTES	= 4096

M.TIMEOUT_DEFAULT   = 60 --s
M.HEARTBEAT_DEFAULT = 30

M.enableDebugMsg 	= false or _G.__FORCE_DUMP_SOCKET_DATA
M.enableDumpPack	= false or _G.__FORCE_DUMP_SOCKET_DATA

M.DEFAULT_SOCKET_NAME = "SOCKET_DEFAULT"

M.sockets = {}

--public function
function M.createSocket(name)
	name = name or M.DEFAULT_SOCKET_NAME
	local socket = M.sockets[name]
	if not socket then
		socket = M(name)
		M.sockets[name] = socket
	end
	return socket
end

function M.get(name)
	return M.createSocket(name)
end

function M.disableAll()
	for k, socket in pairs(M.sockets) do
		socket:setEnabled(false)
	end
end

function M.enableAll()
	for k, socket in pairs(M.sockets) do
		socket:setEnabled(true)
	end
end

function M:init(name)
	self.name 		= name or M.DEFAULT_SOCKET_NAME
	self.timeout    = M.TIMEOUT_DEFAULT
	self.heartbeat  = M.HEARTBEAT_DEFAULT
	self.host 		= nil
	self.port 		= nil
	self.readFD 	= {}
	self.writeFD 	= {}
	self.sendBuffer = {}
	self.recvBuffer	= {}
	self.lastActiveTime 	= 0
	self.lastKeepLiveTime 	= 0
	self.receiveStatus 		= nil
	self.hSocket 			= nil
	self.enabled    = true
	self.packer 	= nil
	self.state 		= M.STATE_IDLE
end
--packer: function required: packer:unpack
function M:setPacker(packer)
	self.packer = packer
end

function M:setAddress(host, port)
	self.host = host
	self.port = port
end

function M:setConnectListener(onSuccess, onFail)
	self.successCB  = onSuccess
	self.failCB		= onFail
end

function M:setEnabled(enable)
	self.enabled = enable
end

function M:setTimeout(sec)
	self.timeout = sec or self.TIMEOUT_DEFAULT
end
function M:setHeartbeat(sec)
	self.heartbeat = sec
end
function M:connect()
	self:close()
	self:setState(M.STATE_TRYCONNECT)
end

function M:sendAsync(data)
	-- assert(self.hSocket)
	assert(self.sendBuffer)
	table.insert(self.sendBuffer, data)
end

function M:send(data)
	self:sendAsync(data)
end

function M:flush()
	if self.state ~= M.STATE_WORKING then
		Logger.error("Socket: flush error, state is not STATE_WORKING!")
		return
	end
	local sendBuffer = self.sendBuffer
	if not sendBuffer or #sendBuffer <= 0 then
		return
	end

	local wholebuffer = table.concat(sendBuffer)

	if string.len(wholebuffer) <= 0 then
		return
	end

	if M.enableDumpPack then

		
		local decodedbuff = self.packer:decode(wholebuffer)
		-- gLog.debug('Socket send:'..gfHex(table.concat(decodedbuff)))
		Logger.info('Socket send:\n'.. string.dumpbuffer(decodedbuff))
	end

	local sent, err = self.hSocket:send( wholebuffer )

	if not sent then
		self:close()
		if self.failCB then
			self.failCB("send error")
		end
		return
	end


	if M.enableDebugMsg then
		Logger.debug(string.format("Socket: send data len: %d ", sent))
	end

	self.lastActiveTime = os.clock()

	-- 抽取尚未发送成功的数据
	wholebuffer = string.sub(wholebuffer, sent + 1)
	self.sendBuffer = {}
	if wholebuffer then 
		if string.len(wholebuffer) > 0 then
			table.insert(self.sendBuffer, wholebuffer)
		end
	end
end

function M.updateSockets()
	for k, socket in pairs(M.sockets) do
		socket:update()
	end
end

function M:update()
	if not self.enabled then
		return
	end
	local stateFuncs = 
	{
		[M.STATE_IDLE] 			= M.updateIdle,
		[M.STATE_TRYCONNECT] 	= M.updateTryConnect,
		[M.STATE_CONNECTING] 	= M.updateConnecting,
		[M.STATE_WORKING] 		= M.updateWorking,
	}

	-- print("..", self.state)
	
	local updateFunc = stateFuncs[self.state]
	if updateFunc then
		updateFunc(self)
	else
		Logger.error("Socket: unkown state:", self.state)
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
		
	self.lastActiveTime = os.clock()
end
function M:updateConnecting()

	local _, _, err = socket.select( nil, self.writeFD, 0 )
	local soundClose = false
	if err == nil then	-- 正常的状态
		-- 连接成功
		if (self.successCB) then
			self.successCB()
		end
		self:setState(M.STATE_WORKING)

	elseif err == "timeout" then

		if (self.lastActiveTime >= 0) then
			local timeUsed = os.clock() - self.lastActiveTime
			if timeUsed > self.timeout then
				soundClose = true
				if M.enableDebugMsg  then
					Logger.debug(string.format('Socket: timeout! hSocket: %s, timeUsed: %d',tostring(self.hSocket), timeUsed))
				end		
			end			
		end
	end

	if soundClose then
		self:setState(M.STATE_IDLE)
		if (self.failCB) then
			self.failCB(err)
		end
	end

end

function M:updateWorking()
	local rt, _, err = socket.select(self.readFD, nil, 0)
	local shouldClose = false
	if err == nil then 
		_, shouldClose = self:receive()
	elseif err == "timeout" then
		--DO NOTHING
	else
		Logger.info("socket select read error!", err)
		shouldClose = true
	end
	-- 检查心跳时间
	if os.clock() - self.lastKeepLiveTime > M.HEARTBEAT_DEFAULT then
		self.packer:onKeepAlive(self.name)
		self.lastKeepLiveTime = os.clock()
	end

	if (self.lastActiveTime >= 0) then
		local timeUsed = os.clock() - self.lastActiveTime
		if timeUsed > M.TIMEOUT_DEFAULT then
			-- shouldClose = true TODO:这里会有奇怪的关闭
			if M.enableDebugMsg then
				print(string.format('socket timeout %s %d',tostring(self.hSocket), timeUsed))
			end		
		end			
	end

	if shouldClose then
		self:close()
	else
		-- 写出数据
		self:flush()
	end
end


function M:close()
	local hSocket = self.hSocket
	if hSocket then
		if M.enableDebugMsg then
			Logger.debug(string.format('Socket: close socket: %s',tostring(hSocket)))
		end	
		hSocket:shutdown()
		hSocket:close()

		table.removeElement(self.readFD,  hSocket)
		table.removeElement(self.writeFD, hSocket)
	end
	self:setState(M.STATE_IDLE)
	self.lastActiveTime = 0
	self.sendBuffer = {}
	self.recvBuffer = {}
	self.hSocket = nil
end

function M:receive()

	local s, status,rest
	local hSocket 		= self.hSocket
	local receiveFinish = false
	local totalReceived = 0
	local recvBuffer = self.recvBuffer
	-- 接收完所有数据
	repeat
		s, status,rest = hSocket:receive(M.MAX_RECEIVE_BYTES)
		if (rest ~= nil ) then
			s = rest
		end
		if (s ~= nil and s ~= "") then
			totalReceived = totalReceived + #s
			local dec_s = self.packer:decode(s)
			table.insert(recvBuffer, dec_s)
			self.lastActiveTime = os.clock()
		else
			receiveFinish = true
		end
	until(receiveFinish)

	if #recvBuffer> 0 then
		if M.enableDumpPack then
			gLog.debug('receive package content:'..gfHex(table.concat(recvBuffer)))
			-- Logger.info('Socket receive:\n'.. string.dumpbuffer(table.concat(recvBuffer)))
		end
		local remain = self.packer:unpack(self.name, table.concat(recvBuffer))
		recvBuffer = {}
		if (remain ~=nil and remain~="" ) then
			table.insert(recvBuffer,remain)
		end
	end


	local isClosed = false
	if status == "closed" or status == "Socket is not connected" then
		if status ~= self.receiveStatus and self.failCB 
		   and self.state ~= M.STATE_IDLE then --主动关闭的情况下不回调给应用（不弹出）
			self.failCB(status)
		end
		isClosed = true
		recvBuffer = {}
	end
	self.recvBuffer = recvBuffer
	self.receiveStatus = status
	return totalReceived, isClosed

end

function M:setState(state)
	self.state = state
end

function M:onTimeout()

end

return M