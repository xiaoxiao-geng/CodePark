local CellRender = class("CellRender", function() return display.newNode() end)

function CellRender:ctor(cell, width, height)
	self.cell = cell

	-- bg
	local bg = cc.LayerColor:create(cc.c4b(255, 255, 255, 64))
		:addTo(self)
		:move(1, 1)
		:setContentSize(width - 2, height - 2)

	-- cloud
	local labelGround = cc.Label:createWithSystemFont("C: 0kg", nil, 12)
		:addTo(self)
		:setAnchorPoint(0, 0)
		:move(4, (height - 4) * 0.6 + 2)

	-- air
	local labelGround = cc.Label:createWithSystemFont("A: 0kg", nil, 12)
		:addTo(self)
		:setAnchorPoint(0, 0)
		:move(4, (height - 4) * 0.4 + 2)

	-- pond
	local labelGround = cc.Label:createWithSystemFont("P: 0kg", nil, 12)
		:addTo(self)
		:setAnchorPoint(0, 0)
		:move(4, (height - 4) * 0.2 + 2)

	-- gound
	local labelGround = cc.Label:createWithSystemFont("G: 0kg", nil, 12)
		:addTo(self)
		:setAnchorPoint(0, 0)
		:move(4, 2)
end

return CellRender