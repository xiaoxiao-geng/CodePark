local M = {}

-- import
local table             = require "hp/lang/table"

-- TODO 额外功能，暂时未实现
-- 1. 取消激活事件，当一个RadioButton被取消激活时转发事件，目前用不到暂时不实现，需要时补上

-- 按钮缓存区
-- 按照groupId进行分组
local buttonCache = {}

local PANEL_GROUP_ID = 10000

-- 获取一个group缓存
-- 如果不存在则创建
local function _getGroupCache( group )
	local groupCache = buttonCache[ group ]

	if not groupCache then
		-- 创建弱引用table
		groupCache = {}
		setmetatable( groupCache ,{ __mode = "kv" } )
		buttonCache[ group ] = groupCache
	end

	return groupCache
end


function M.printCache()
	print( " () ()\n( @ @ )\n(  -  )    RadioButton cache:")
	for group, cache in pairs( buttonCache ) do
		print( "  group:", group, cache )
		if cache then
			for k, v in pairs( cache ) do
				print("    button:", v.name, v )
			end
		end
	end
end

-- 生成一个panel groupId（用于默认值）
function M.generalPanelGroupId()
	PANEL_GROUP_ID = PANEL_GROUP_ID + 1
	return PANEL_GROUP_ID
end

-- 将按钮添加到缓存中
function M.addRadioButton( button )
	if not button then return end
	if not button.getGroupId then return end

	local groupCache = _getGroupCache( button:getGroupId() )
	table.insert( groupCache, button )
end

-- 将按钮从缓存中删除
function M.removeRadioButton( button )
	if not button then return end
	if not button.getGroupId then return end

	local groupCache = _getGroupCache( button:getGroupId() )
	table.removeElement( groupCache, button )
end

-- 当一个button激活后调用
function M.onButtonActive( button )
	if not button then return end
	if not button.getGroupId then return end
	if not button.setActived then return end

	-- 1. 取消所有同组的按钮激活状态
	local groupCache = _getGroupCache( button:getGroupId() )
	for k, v in pairs( groupCache ) do
		if v ~= button and v.setActived then
			v:setActived( false )
		end
	end

	-- 2. 激活按钮
	button:setActived( true )
end

-- 设置所有按钮的状态
function M.setGroupActived( group, value )
	local groupCache = _getGroupCache( group )
	for k, v in pairs( groupCache ) do
		if v.setActived then
			v:setActived( value )
		end
	end
end

return M