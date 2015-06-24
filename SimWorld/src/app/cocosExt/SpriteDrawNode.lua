--[[
	采用Sprite进行绘图的DrawNode替代方案

	在 cocos2d-x 3.4 中
	使用DrawNode作为ClippingNode的stencil，在Android设备上，clip会失效
	目前发现可以采用绘制Sprite的方式绕过这个问题

	这个文件便为此用

	若以后cocos2d-x更新后，修复了上述的bug，此文件将无用
]]

local SpriteDrawNode = class("SpriteDrawNode", function()
	local node = display.newNode()
	return node
	end)

local DEFAULT_COLOR = cc.c4b(255, 255, 255, 255)
local BRASH_TEXTURE = "ui/common/brash_20.png"
local BRASH_TEXTURE_SIZE = 20

function SpriteDrawNode:ctor()
	self.brashTexture = brashTexture or BRASH_TEXTURE
	self.brashTextureSize = BRASH_TEXTURE_SIZE

	self.brashSize = self.brashTextureSize
	self.brashScale = self.brashSize / self.brashTextureSize

	self.lineGap = self.brashSize / 2
	self.limitGap = self.lineGap / 2

	self.sprites = {}
end

function SpriteDrawNode:setBrashTexture(texture)
	self.brashTexture = texture

	local sprite = cc.Sprite:create(texture)
	local size = sprite:getContentSize()
	sprite:addTo(self):removeFromParent()

	self.brashTextureSize = math.min(size.width, size.height)

	return self
end

function SpriteDrawNode:setBrashSize(size)
	self.brashSize = size
	self.brashScale = size / self.brashTextureSize
	self.lineGap = self.brashSize / 2
	self.limitGap = self.lineGap / 2

	print("brashScale", self.brashScale)

	return self
end

function SpriteDrawNode:draw(p, color)
	p.x = math.floor(p.x)
	p.y = math.floor(p.y)

	if not self:_checkPoint(p) then return end

	color = color or DEFAULT_COLOR

	local sprite = cc.Sprite:create(self.brashTexture)
		:addTo(self)
		:move(p)
		:setColor(color)
		:setScale(self.brashScale)

	table.insert(self.sprites, sprite)
end

function SpriteDrawNode:_checkPoint(p)
	local limit = self.limitGap

	local minX = p.x - limit
	local maxX = p.x + limit
	local minY = p.y - limit
	local maxY = p.y + limit

	local sprites = self.sprites
	local sprite
	local x, y
	for i = 1, #sprites do
		sprite = sprites[i]
		x, y = sprite:getPosition()

		if x >= minX and x <= maxX and y >= minY and y <= maxY then return false end
	end

	return true
end

--- 绘制一条线
-- 原理是，在线的连线上，绘制所有的点
-- 如果末尾距离不够，则追加draw一个
function SpriteDrawNode:drawSegment(p1, p2, color)
	color = color or DEFAULT_COLOR

	local line = cc.pSub(p2, p1)
	local normal = cc.pNormalize(line)
	local len = math.sqrt(cc.pLengthSQ(line))

	local n = 0
	local p
	while true do
		p = cc.pMul(normal, n)

		self:draw(cc.pAdd(p1, p), color)

		n = n + self.lineGap
		if n >= len then break end
	end

	self:draw(p2, color)
end

function SpriteDrawNode:clear()
	for i, v in pairs(self.sprites or {}) do
		if v then v:removeFromParent() end
	end
	self.sprites = {}
end

return SpriteDrawNode