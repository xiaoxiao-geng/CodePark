--[[
	File Desc:状态机，与FSMRoot配套使用
]]

local FSMObject = class( "FSMObject" )

cc.exports.ST_NONE = -1




function FSMObject:ctor()
	-- 预设空状态
	self._currentStateID = ST_NONE
	self._nextStateID = ST_NONE
	self._states = {
		[ ST_NONE ] = { leave = nil, execute = nil, enter = nil }
	}
	
	self._privateIndex = nil

	self._children = nil
end


-- 获取唯一索引
function FSMObject:getObjIndex()
	return self._privateIndex
end


function FSMObject:registerState( stateID, enter, execute, leave )
	self._states[ stateID ] = { enter = enter, execute = execute, leave = leave }
end


function FSMObject:removeState( stateID )
	self._states[ stateID ] = nil
end


function FSMObject:addChild( child )
	if not child then
		return
	end
	
	if not self._children then
		self._children  = {}
	end

	table.insert( self._children,child )
end


function FSMObject:delChild( child )
	if self._children and child then
		local t = self._children
		for i,v in ipairs( t ) do
			if v == child then
				table.remove( t, i )
				break
			end
		end
	end
end


function FSMObject:update( ... )
	-- print( "update state:", self._currentStateID )
	if self._nextStateID ~= self._currentStateID then
		local leave = self._states[ self._currentStateID ].leave
		if leave then
			leave( self )
		end

		self._currentStateID = self._nextStateID

		local enter = self._states[ self._currentStateID ].enter
		if enter then
			enter( self )
		end
	end

	local callback = self._states[ self._currentStateID ].execute
	if callback then
		callback( self, ... )
	end
end


function FSMObject:setNextState( stateID )
	-- print( "setNextState:", stateID, self._states[ stateID ] )
	self._nextStateID = stateID
end


function FSMObject:getState()
	return self._currentStateID
end


-- 回收接口，FSMRoot移除后的回调方法
function FSMObject:recycle()
end


function FSMObject:dispose()
	self._states = nil
end


function FSMObject:removeFromRoot()
	self._bPendingRemove = true
end



return FSMObject