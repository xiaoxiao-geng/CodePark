local super		= Page
local M			= class( super )

function M:onCreate()
	print("moduleB:onCreate")
	print("  size", self:getSize())

	Sprite { parent = self, pos = { 10, 10 }, texture = "NPC/529.png" }

	CustomButton { parent = self, pos = { 300, 100 }, size = { 100, 50 }, text = "按钮1" }
	CustomButton { parent = self, pos = { 300, 200 }, size = { 100, 50 }, text = "按钮1" }
	
	self:addDataListener( "data2", M.onReceiveData2 )
end

function M:onDestory()
	gDialog.fShowTip( self.getTitle().text .. " 销毁" )
end

function M.getTitle()
	return { text = "B", textureName = "B" }
end

function M:onReceiveData2( data )
	gDialog.fShowTip( self.getTitle().text .. "接收data2: " .. data )
end

return M