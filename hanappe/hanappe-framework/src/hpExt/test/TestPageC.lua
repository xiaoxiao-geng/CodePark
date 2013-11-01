local super		= Page
local M			= class( super )

function M:onCreate()
	Sprite { parent = self, pos = { 10, 10 }, texture = "NPC/540.png" }

	CustomButton { parent = self, pos = { 300, 100 }, size = { 100, 50 }, text = "按钮1" }
	CustomButton { parent = self, pos = { 300, 200 }, size = { 100, 50 }, text = "按钮1" }
	
	self:addDataListener( "data1", M.onReceiveData1 )
	self:addDataListener( "data2", M.onReceiveData2 )
end

function M:onDestory()
	gDialog.fShowTip( self.getTitle().text .. " 销毁" )
end

function M.getTitle()
	return { text = "C", textureName = "C" }
end

function M:onReceiveData1( data )
	gDialog.fShowTip( self.getTitle().text .. "接收data1: " .. data )
end

function M:onReceiveData2( data )
	gDialog.fShowTip( self.getTitle().text .. "接收data2: " .. data )
end

return M