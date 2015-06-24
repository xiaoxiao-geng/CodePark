--[[
	File Desc:状态机管理器，用于管理世界中的成员
]]

local FSMRoot = class( "FSMRoot" )

-- 下一个要分配的索引(全局唯一标志)
local _nextIndex = 1



function FSMRoot:ctor()
	-- 用于放置所有对象的列表
	self.fsmObjects = {}
end


function FSMRoot:addObject( obj )
	self.fsmObjects[ _nextIndex ] = obj
	obj._privateIndex = _nextIndex
	_nextIndex = _nextIndex + 1
end


-- remove标记
function FSMRoot:removeObject( obj )
	if obj._privateIndex and (not obj._bPendingRemove) then
		obj._bPendingRemove = true
		return true
	end
	return false
end


function FSMRoot:processPendingRemove()
	local objs = self.fsmObjects
    for k, obj in pairs( objs ) do
        if obj._privateIndex and obj._bPendingRemove then
			objs[ obj._privateIndex ] = nil
			obj._privateIndex = nil
			obj._bPendingRemove = nil
			obj:recycle()
		end
	end
end


function FSMRoot:update( ... )
	for _, obj in pairs( self.fsmObjects ) do
		if not obj._bPendingRemove then
			obj:update( ... )
		end
	end
	self:processPendingRemove()
end


function FSMRoot:dispose()
	for _, obj in pairs( self.fsmObjects ) do
		self:removeObject( obj )
	end
	self:processPendingRemove()

	self.fsmObjects = nil
end


return FSMRoot
