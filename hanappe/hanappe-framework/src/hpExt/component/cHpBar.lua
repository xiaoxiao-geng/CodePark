
local Component 		= require "hp/gui/Component"
local class 			= require "hp/lang/class"
local Executors         = require "hp/util/Executors"

local super 			= Component
local M 				= class( super )

function M:createChildren()
	super.createChildren( self )

	-- 采用三层NinePatch的方式进行设计
	-- 这里分析下各层次的逻辑关系
	-- 
	self.bar3 = NinePatch { parent = self, texture = "skins/slider_progress.png", color = { 0.2, 0.2, 0.2, 1} }
	self.bar2 = NinePatch { parent = self, texture = "skins/slider_progress.png", color = { 1, 0, 0, 1 } }
	self.bar1 = NinePatch { parent = self, texture = "skins/slider_progress.png" }

	self.hp, self.maxHp = 1, 1
	self.buff = 0
    
    Executors.callLoop( M.update, self )
end

function M:resizeHandler()
	super.resizeHandler( self )

	local w, h = self:getSize()
	self.bar2:setSize( w, h )
	self.bar3:setSize( w, h )

	self:refresh()
end

function M:setValue( hp, maxHp )
	if hp > maxHp then hp = maxHp end
	if hp < 0 then hp = 0 end

	self.hp, self.maxHp = hp, maxHp
	self.buffSpeed = maxHp / 5 / 60

	self:refresh()
end

function M:setHp( hp )
	self:setValue( hp, self.maxHp )
end

function M:setBuff( buff )
	if self.buff == buff then return end
	self.buff = buff

	local w, h = self:getSize()

	local hpAlpha = buff / self.maxHp

	self.bar2:setSize( w * hpAlpha, h )
end

function M:refresh()
	local hp, maxHp = self.hp, self.maxHp

	local w, h = self:getSize()

	local hpAlpha = hp / maxHp

	self.bar1:setSize( w * hpAlpha, h )
end

function M:update()
	local hp, buff, max = self.hp, self.buff, self.maxHp

	-- buff比HP低，直接设置为HP
	if buff < hp then self:setBuff( hp ) return end

	if buff > hp then
		buff = buff - self.buffSpeed
		self:setBuff( buff )
	end
end

return M