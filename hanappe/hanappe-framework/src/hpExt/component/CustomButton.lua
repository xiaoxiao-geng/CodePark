----------------------------------------------------------------
-- This class is a extension button.
----------------------------------------------------------------

-- import
local table             = require "hp/lang/table"
local class             = require "hp/lang/class"
local Event             = require "hp/event/Event"
local Button         	= require "hp/gui/Button"

-- class define
local M                 = class( Button )
local super             = Button

--------------------------------------------------------------------------------
-- Initializes the internal variables.
--------------------------------------------------------------------------------
function M:initInternal()
	super.initInternal( self )

	self._customSkin = {}
end

function M:createChildren()
    local skinClass = self:getStyle("skinClass")
    self._skinClass = skinClass
    self._background = skinClass(self:getStyle("skin"))

    local w, h = self._background:getSize()
    
    self._label = TextLabel()
    self._label:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
    self._label:setSize( math.even( w ), math.even( h ) )

    self:addChild(self._background)
    self:addChild(self._label)

    self:setSize( w, h )

	if self._contentTexture then
		self:createContentSprite()
	end
end

function M:updateDisplay()
	super.updateDisplay( self )

	if self._contentSprite then
		self._contentSprite:setColor(unpack(self:getStyle("skinColor")))
	end
end

function M:resizeHandler( e )    
	local background = self._background
    background:setSize(self:getWidth(), self:getHeight())

    local textPadding = self:getStyle("textPadding")
    local paddingLeft, paddingTop, paddingRight, paddingBottom = unpack(textPadding)

    local label = self._label

    local fEven = math.even

    local left, right = fEven( paddingLeft ), fEven( paddingRight )
    local top, bottom = fEven( paddingTop ), fEven( paddingBottom )
    local w, h = fEven( self:getWidth() - left - right ), fEven( self:getHeight() - top - bottom )

    label:setSize( w, h )
    -- 说明：多次取偶数之后，导致文字偏上，很奇怪，这里使用两个像素进行修正
    label:setPos( left, top )

	self:setCenterPiv()
end

-- 设置按钮正常状态图片
function M:setNormalTexture( texture )
	self._customSkin.normal = texture
end

-- 设置按钮选中状态图片
function M:setSelectedTexture( texture )
	self._customSkin.selected = texture
end

-- 设置按钮不可用状态图片
function M:setDisabledTexture( texture )
	self._customSkin.disabled = texture
end

-- 设置作为内容图片
function M:setContentTexture( texture )
	self._contentTexture = texture

	if self._contentSprite then
		self:_setContentSpriteTexture()
	else
		self:createContentSprite()
	end
end

function M:createContentSprite()
	if not self._contentTexture then return end

	local content = Sprite()
	self:addChild( content )

	self._label:moveToFront()

	self._contentSprite = content

	self:_setContentSpriteTexture()
end

function M:_setContentSpriteTexture()
	local content = self._contentSprite
	content:setTexture( self._contentTexture )

	local w, h = self:getSize()
	local cw, ch = content:getSize()

	content:setPos(
		math.floor( ( w - cw ) * 0.5 ),
		math.floor( ( h - ch ) * 0.5 )
		)
end

-- 拦截style中的skin属性，使用自定义的主题
function M:getStyle( name, state )
	state = state or self:getCurrentState()

	-- print("getCustomSkin", name, state)
	if name == "skin" then
		local skin = self._customSkin[ state ]
		-- print("  skin", skin)
		if skin then return skin end

		local normalSkin = self._customSkin[ state ]
		-- print("  normalSkin", normalSkin)
		if normalSkin then return normalSkin end
	end

	return super.getStyle( self, name, state )
end











-- 重写Button中的方法，将事件引导至doCancelButton
function M:touchMoveHandler(e)
    if e.idx ~= self._touchIndex then
        return
    end
    e:stop()
    
    if self._touching and not self:hitTestWorld(e.x, e.y) then
        self._touching = false
        self._touchIndex = nil
        
        if not self:isToggle() then
            self:doCancelButton()
            self:dispatchEvent(M.EVENT_CANCEL)
        end
    end
end

-- 重写Button中的方法，将事件引导至doCancelButton
function M:touchCancelHandler(e)
	if not self._touching then return end

    if not self:isToggle() then
        self._touching = false
        self._touchIndex = nil
        
        self:doCancelButton()
        self:dispatchEvent(M.EVENT_CANCEL)
    end
end
















-- 动画相关
function M:dispose()
	if self._anim then
		self:_stopAnim()
	end

	super.dispose( self )
end

local rate = 0.75
function M:doDownButton()
	super.doDownButton( self )

	-- self:_stopAnim()
	-- self._anim = Animation( self ):
	-- 	seekScl( 0.85, 0.85, 1, 0.1, Ease.ein )
	-- self._anim:play()

	self:_stopAnim()
	self._anim = Animation( self ):
		seekScl( 1.15, 1.15, 1, 0.1, Ease.ein )
	self._anim:play()
end

function M:doUpButton()
	super.doUpButton( self )

	-- self:_stopAnim()
	-- self._anim = Animation( self ):
	-- 	seekScl( 1.15, 1.15, 1, 0.2, Ease.smooth ):
	-- 	seekScl( 0.925, 0.925, 1, 0.15, Ease.out ):
	-- 	seekScl( 1.05, 1.05, 1, 0.1, Ease.smooth ):
	-- 	seekScl( 1, 1, 1, 0.05, Ease.out )
	-- self._anim:play()

	self:_stopAnim()
	self._anim = Animation( self ):
		seekScl( 0.9, 0.9, 1, 0.1, Ease.ein ):
		seekScl( 1.05, 1.05, 1, 0.075, Ease.linear ):
		seekScl( 1, 1, 1, 0.03, Ease.linear )
	self._anim:play()
end

function M:doCancelButton()
	super.doUpButton( self )

	-- self:_stopAnim()
	-- self._anim = Animation( self ):
	-- 	seekScl( 1.05, 1.05, 1, 0.15, Ease.smooth ):
	-- 	seekScl( 1, 1, 1, 0.1, Ease.out )
	-- self._anim:play()

	self:_stopAnim()
	self._anim = Animation( self ):
		seekScl( 0.95, 0.95, 1, 0.15, Ease.smooth ):
		seekScl( 1, 1, 1, 0.1, Ease.out )
	self._anim:play()
end

function M:_stopAnim()
	if self._anim then
		self._anim:stop()
		self._anim = nil
	end
end

return M