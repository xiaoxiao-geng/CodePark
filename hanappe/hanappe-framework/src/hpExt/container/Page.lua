-- Page

-- import
local table		= require "hp/lang/table"
local class		= require "hp/lang/class"
local Component	= require "hp/gui/Component"

-- class
local super		= Component
local M			= class( super )

function M:init( ... )
	self.dataListeners = {}

	super.init( self, ... )
end

function M:dispose()
	self.dataListeners = {}
	self:stopPageAnimation()
	self:onDestory()

	super.dispose( self )
end

-- -- overload
-- function M:initComponent( ... )
-- 	super.initComponent( self, ... )

-- 	self:onCreate()
-- end




-- function M:setSize( ... )
-- 	print("Page.setSize", self, ... )
-- 	-- print(debug.traceback())
-- 	super.setSize( self, ... )
-- end





-- title相关

function M.getTitle()
	return "no-name"
end






-- 动画相关

function M:stopPageAnimation()
	if self._pageAnim then
		self._pageAnim:stop()
		self._pageAnim = nil
		self._pageAnimCallback = nil
	end
end

function M:playPageAnimation( anim, callback )
	self:stopPageAnimation()

	self._pageAnim = anim
	self._pageAnimCallback = callback

	anim:play( { onComplete = function() 
			if self._pageAnimCallback then
				self._pageAnimCallback()
			end
			
			self._pageAnim = nil
			self._pageAnimCallback = nil
		end } )
end





-- 流程方法

-- 控件打开，注册监听器
function M:enter()
	self:onEnter()
	self:addListeners()
end

-- 控件关闭，卸载数据监听器
function M:leave()
	self:removeListeners()
	self:onLeave()
end

-- 激活控件（动画播放完毕） *目前没发现有任何用
function M:active()
	self:onActive()
end

-- 禁用控件（开始播放动画） *目前没发现有任何用
function M:disable()
	self:onDisable()
end









-- 路由器时间接收方法
function M:routerHandler( e )
	local listeners = self.dataListeners
	local callback = listeners[ e.type ]
	if callback then
		callback( self, e.data )
	end
end

-- 添加监听器到监听器队列
function M:addDataListener( type, callback )
	self.dataListeners[ type ] = callback
end

-- 向路由器注册监听器队列
function M:addListeners()
	local listeners = self.dataListeners
	for k, v in pairs( listeners ) do
		Router:addEventListener( k, M.routerHandler, self )
	end
end

-- 将监听器队列从路由器中卸载
function M:removeListeners()
	local listeners = self.dataListeners
	for k, v in pairs( listeners ) do
		Router:removeEventListener( k, M.routerHandler, self )
	end
end










-- 生命周期回调，提供子类覆写
function M:onCreate()
	print("Page.onCreate", self.getTitle())
end

function M:onDestory()
	print("Page.onDestory", self.getTitle())
end

function M:onEnter()
	print("Page.onEnter", self.getTitle())
end

function M:onLeave()
	print("Page.onLeave", self.getTitle())
end

function M:onActive()
	print("Page.onActive", self.getTitle())
end

function M:onDisable()
	print("Page.onCreate", self.getTitle())
end

return M