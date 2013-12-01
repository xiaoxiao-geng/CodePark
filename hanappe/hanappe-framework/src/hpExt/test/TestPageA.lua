local super		= Page
local M			= class( super )

function M:onCreate()
	Sprite { parent = self, pos = { 10, 10 }, texture = "NPC/505.png" }

	CustomButton { parent = self, pos = { 300, 100 }, size = { 100, 50 }, text = "按钮1" }
	CustomButton { parent = self, pos = { 300, 200 }, size = { 100, 50 }, text = "按钮1" }

	self:addDataListener( "data1", M.onReceiveData1 )
end

function M:onDestory()
	gDialog.fShowTip( self.getTitle().text .. " 销毁" )
end

function M.getTitle()
	return { text = "A", texture = "ml/button/tab/A.png" }
end

function M:onReceiveData1( data )
	gDialog.fShowTip( self.getTitle().text .. "接收data1: " .. data )
end

return M