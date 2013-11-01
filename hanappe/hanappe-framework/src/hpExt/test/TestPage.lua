-- TestPage

-- import
local table		= require "hp/lang/table"
local class		= require "hp/lang/class"
local Component	= require "hp/gui/Component"
local Page		= require "hpExt/container/Page"

-- class
local super		= Page
local M			= class( super )

function M:onCreate()
	super.onCreate( self )

	local btn = CustomButton { parent = self, pos = { 50, 50 }, size = { 100, 50 }, text = "hello", onClick = function() 
		gDialog.fShowTip( "click hello" )
		end }

	self.button = btn

	self:addDataListener( "data1", M.onReceiveData1 )
	self:addDataListener( "data2", M.onReceiveData2 )
end

function M:onDestory()
	self.button = nil

	if self.anim then
		self.anim:stop()
		self.anim = nil
	end

	super.onDestory( self )
end

function M:onEnter()
	super.onEnter( self )

	local anim = Animation():loop( -1, Animation( self.button, 1 ):seekLoc( 200, 50 ):seekLoc( 50, 50 ) )
	anim:play()

	self.anim = anim
end

function M:onLeave()
	super.onLeave( self )

	if self.anim then
		self.anim:stop()
	end
end

function M:onReceiveData1( data )
	print("TestPage.onReceiveData1", data )
end

function M:onReceiveData2( data )
	print("TestPage.onReceiveData2", data )
end

return M