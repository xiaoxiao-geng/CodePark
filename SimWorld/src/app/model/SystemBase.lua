local SystemBase = class("SystemBase")

function SystemBase:ctor(world)
	self.world = world
end

--- 更新
-- @param elapsed 两次更新间隔 单位秒
function SystemBase:update(elapsed)
end

return SystemBase