----------------------------------------------------------------
-- This class is a extension button.
----------------------------------------------------------------

-- import
local table             = require "hp/lang/table"
local class             = require "hp/lang/class"
local Event             = require "hp/event/Event"
local CustomButton     	= require "hpExt/component/CustomButton"

-- class define
local M                 = class( CustomButton )
local super             = CustomButton

M.EVENT_ACTIVE_CHANGED 	= "onActiveChanged"

local function getParentGroupId( parent )
	while true do
		if not parent then return nil end

		if parent.getPanelGroupId then
			return parent:getPanelGroupId()
		end

		if not parent.getParent then return nil end
		parent = parent:getParent()
	end
end

--------------------------------------------------------------------------------
-- Initializes the internal variables.
--------------------------------------------------------------------------------
function M:initInternal()
	super.initInternal( self )

	self._groupId = 0
	self._actived = false
	self._themeName = "RadioButton"
end

function M:initComponent( params )
	-- 尝试在父面板中找到默认id
	if not params.groupId then
		local id = getParentGroupId( params.parent )
		if not id then error( "RadioButton groupId not found!" ) end
		params.groupId = id
	end

	super.initComponent( self, params )
end

function M:setGroupId( value )
	self._groupId = value

	RadioButtonManager.removeRadioButton( self )
	RadioButtonManager.addRadioButton( self )
end

function M:getGroupId()
	return self._groupId
end

function M:isActived()
	return self._actived
end

function M:setActived( value )
	if self._actived == value then return end

	-- 如果是改变为激活，则提交RadioButton处理
	if value == true then
		self._actived = true
        self:dispatchEvent( M.EVENT_ACTIVE_CHANGED )
		RadioButtonManager.onButtonActive( self )
	else
		self._actived = false
	end

	self:updateDisplay()
end






--------------------------------------------------------------------------------
-- 覆写touchUp
-- @param e Touch Event
--------------------------------------------------------------------------------
function M:touchUpHandler(e)
    if e.idx ~= self._touchIndex then
        return
    end
    e:stop()
    
    if self._touching and not self:isToggle() then
        self._touching = false
        self._touchIndex = nil
        
        self:doUpButton()

        -- 触发点击事件
        self:dispatchEvent(M.EVENT_CLICK)
        
        -- 设置为激活
        self:setActived( true )
    end
end

function M:setVisible( value )
	super.setVisible( self, value )

	self:_updateActiveDisplay( value )
end

function M:updateDisplay()
	super.updateDisplay( self )

	self:_updateActiveDisplay()
end









-- 创建激活状态skin
function M:_createActiveComponent()
	local activeClass = self:getStyle( "activeSkinClass" )
	local activeSkin = self:getStyle( "activeSkin" )
	local useTextureSize = self:getStyle( "activeUseTextureSize" ) == true

	if not activeClass then error( "RadioButton acive skin class not found!" ) end
	if not activeSkin then error( "RadioButton active skin not found!" ) end

	-- print( "RadioButton:_createActiveComponent", self.name )
	-- print( "  activeClass", activeClass )
	-- print( "  activeSkin", activeSkin )

	local component = activeClass( activeSkin )

	-- 使用Texture自身的尺寸
	if useTextureSize then
		local w, h = component:getSize()
		local pw, ph = self:getSize()

		local x, y = math.even( ( pw - w ) / 2 ), math.even( ( ph - h ) / 2 )
		component:setPos( x, y )
	else
		component:setSize( self:getSize() )
	end
	self:addChild( component )

	self._activeComponent = component
end

-- 更新选中框的显示状态
function M:_updateActiveDisplay( visible )
	local actived = self._actived
	if visible == nil then visible = self:getVisible() end

	-- print( "RadioButton:_updateActiveDisplay", self.name )
	-- print( "  component", self._activeComponent )
	-- print( "  active", actived )
	-- print( "  visible", visible )

	-- 1. 更新按钮的样式
	if actived then
		local skinColor = self:getStyle( "activeSkinColor" )
		if skinColor then
			self._background:setColor( unpack( skinColor ) )
			if self._contentSprite then
				self._contentSprite:setColor( unpack( skinColor ) )
			end
		end

		local textColor = self:getStyle( "activeTextColor" )
		if textColor then
			self._label:setColor( unpack( textColor ) )
		end
	end

	-- 2. 尝试创选中框控件
	if not self._activeComponent then
		-- 优化点，如果不显示激活，并且没有控件，则不处理
		if not actived then return end

		self:_createActiveComponent()
	end

	-- 3. 设置选中框是否可见
	local component = self._activeComponent
	component:setVisible( actived and visible )
end

return M