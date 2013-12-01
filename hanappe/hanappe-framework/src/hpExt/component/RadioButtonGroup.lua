----------------------------------------------------------------
-- RadioButtonGroup 管理多个RadioButton的容器
----------------------------------------------------------------

-- import
local class		= require "hp/lang/class"
local Event		= require("hp/event/Event")
local Component	= require "hp/gui/Component"

-- class
local super		= Component
local M			= class( super )

local MODE_VERTICAL	= 1
local MODE_HORZION	= 2

M.EVNET_SELECTED = "buttonSelected"

function M:initInternal()
	super.initInternal( self )

	self._align = Direction.left

	self._buttonWidth, self._buttonHeight = 10, 10
	self._buttonSpacing = 0

	self._beginId = 1

	self._buttonGroupId = RadioButtonManager.generalPanelGroupId()

	self._datas = {}
	self._buttons = {}

	self._fillParent = true
end

function M:createChildren()
	super.createChildren( self )

	self:_setMode( self._mode or MODE_HORZION )

	self:_createButton()
end

function M:setVisible( value )
	super.setVisible( self, value )

	if value then
		self:_updateLayout()
	end
end

function M:setBeginId( value )
	self._beginId = value
end

-- 设置水平对齐方式
function M:setHorizonAlign( align )
	self:_setMode( MODE_HORZION )

	self:_setAlign( align )
end

-- 设置垂直对齐方式
function M:setVerticalAlign( align )
	self:_setMode( MODE_VERTICAL )

	self:_setAlign( align )
end

-- 设置垂直、水平模式
function M:_setMode( mode )
	print("Group._setMode", mode)
	if self._mode == mode then return false end

	self._mode = mode

	if mode == MODE_HORZION then
		self:setLayout( HBoxLayout { 
			spacing = { 0, 0, 0, 0 },
			gap = { self._buttonSpacing, self._buttonSpacing },
			} )

	elseif mode == MODE_VERTICAL then
		self:setLayout( VBoxLayout { 
			spacing = { 0, 0, 0, 0 },
			gap = { self._buttonSpacing, self._buttonSpacing },
			} )
	end
end

function M:_setAlign( align )
	if not align then return end

	if type( align ) == "string" then
		align = Direction[ align ]
	end

	if not align then
		error( "RadioButtonGroup: wrong align: " .. tostring( align ) )
	end

	-- 设置到layout中
	local layout = self:getLayout()
	if layout then
		-- 水平
		local ha, va = "center", "center"
		
		if Direction.isLeft( align ) 		then ha = "left"
		elseif Direction.isRight( align ) 	then ha = "right" end
		
		if Direction.isTop( align ) 		then va = "top"
		elseif Direction.isBottom( align ) 	then va = "bottom" end

		layout:setAlign( ha, va )
	end

	self._align = align
end

function M:setButtonSize( w, h )

	print("Group.setButtonSize", w, h)
	self._buttonWidth = w
	self._buttonHeight = h
end

function M:setButtonSpacing( spacing )
	self._buttonSpacing = spacing

	local layout = self:getLayout()
	if layout then
		layout:setGap( spacing, spacing )
	end
end

function M:setButtonTheme( theme )
	self._buttonTheme = theme
end

function M:setOnSelected( callback )
	self:addEventListener( M.EVNET_SELECTED, callback )
end

function M:setTexts( texts, ... )
	if type( texts ) ~= "table" then
		texts = { texts, ... }
	end

	local datas = {}
	for k, v in pairs( texts ) do
		table.insert( datas, { text = v, visibled = true } )
	end

	self._datas = datas

	self:_createButton()
end

function M:setTextures( textures, ... )
	if type( textures ) ~= "table" then
		textures = { textures, ... }
	end

	local datas = {}
	for k, v in pairs( textures ) do
		table.insert( datas, { texture = v, visibled = true } )
	end

	self._datas = datas

	self:_createButton()
end

function M:getButton( id )
	id = id - self._beginId + 1
	for k, v in pairs( self._buttons ) do
		if k == id then return v end
	end

	return nil
end

function M:_getData( id )
	id = id - self._beginId + 1

	for k, v in pairs( self._datas ) do
		if k == id then return v end
	end

	return nil
end

function M:isButtonVisibled( id )
	local data = self:_getData( id )
	if data and data.visibled then return true end
	return false
end

function M:setButtonVisibled( id, visibled )
	local data = self:_getData( id )
	if data and data.visibled ~= visibled then
		data.visibled = visibled
		self:_updateLayout()
	end
end

function M:isButtonEnabled( id )
	local button = self:getButton( id )
	if button and button:isEnabled() then return true end
	return false
end

function M:setButtonEnabled( id , enabled )
	local button = self:getButton( id )
	if button and button:isEnabled() ~= enabled then
		button:setEnabled( enabled )
	end
end

function M:setButtonActived( id, actived )
	local button = self:getButton( id )
	if button and button:isActived() ~= actived then
		button:setActived( actived )
	end
end

function M:select( id )
	self:setButtonActived( id, true )
end







function M:onButtonClick( e )
	local button = e.target

	local event = Event( M.EVNET_SELECTED )
	event.selectedId = button.id
	self:dispatchEvent( event )
end

function M:_disposeButton()
	local buttons = self._buttons
	for i = #buttons, 1, -1 do
		buttons[ i ]:dispose()
	end
	self._buttons = {}
end

-- 创建RadioButton
function M:_createButton()
	self:_disposeButton()

	local datas = self._datas
	local count = table.getn( datas )
	if count <= 0 then return end

	local w, h = self._buttonWidth, self._buttonHeight
	local theme = self._buttonTheme
	local groupId = self._buttonGroupId

	-- 1. 计算起始坐标
	local beginX, beginY = 0, 0

	-- 2. 计算每一个按钮的坐标
	local buttons = {}

	for i, data in pairs( datas ) do
		local text = data.text
		local texture = data.texture

		local button = RadioButton { 
			parent = self,
			size = { w, h },
			themeName = theme,
			text = text,
			contentTexture = texture,
			groupId = groupId,
			}

		button:addEventListener( RadioButton.EVENT_ACTIVE_CHANGED, M.onButtonClick, self )

		table.insert( buttons, button )
		button.id = i + self._beginId - 1
	end

	self._buttons = buttons

	self:_updateLayout()
end

function M:_updateLayout()
	local buttons = self._buttons
	local datas = self._datas

	for i = 1, #datas do
		local data = datas[ i ]
		local button = buttons[ i ]

		if data.visibled then
			button:show()
			button:setIncludeLayout( true )
		else
			button:hide()
			button:setIncludeLayout( false )
		end
	end
end

function M:_getPosByIndex( index, count )
	local w, h = self._buttonWidth, self._buttonHeight
	local spacing = self._buttonSpacing
	local align = self._align
	local mode = self._mode

	local i = index - 1
	local x, y = 0, 0

	if mode == MODE_HORZION then
		-- 水平对齐
		local tw = w * count + spacing * ( count - 1 )

		-- x坐标
		if Direction.isVCenter( align ) then 	x = ( tw * -0.5 ) + ( w + spacing ) * i
		elseif Direction.isRight( align ) then 	x = - w * ( i + 1 ) - spacing * i
		else 									x = ( w + spacing ) * i
		end

		-- y坐标
		if Direction.isHCenter( align ) then 	y = h * -0.5
		elseif Direction.isBottom( align ) then y = -h
		else 									y = 0
		end

	else
		-- 垂直对齐
		local th = h * count + spacing * ( count - 1 )

		-- x坐标
		if Direction.isVCenter( align ) then 	x = w * -0.5
		elseif Direction.isRight( align ) then 	x = -w
		else 									x = 0
		end

		-- y坐标
		if Direction.isHCenter( align ) then 	y = ( th * -0.5 ) + ( h + spacing ) * i
		elseif Direction.isBottom( align ) then y = -h * ( i + 1 ) - spacing * i
		else 									y = ( h + spacing ) * i
		end
	end

	return math.even( x ), math.even( y )
end

return M