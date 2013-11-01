-- Dialog

-- import
local table		= require "hp/lang/table"
local class		= require "hp/lang/class"
local NinePatch	= require "hp/display/NinePatch"
local TextLabel	= require "hp/display/TextLabel"
local Event		= require "hp/event/Event"
local Panel		= require "hp/gui/Panel"

-- class define
local super		= Panel
local M			= class( super )

local PADDING	= HP_PANEL_PADDING
local GAP		= HP_PANEL_GAP

function M:init( ... )
	self._themeName = "PanelFrame02"
	super.init( self, ... )
end

function M:createChildren()
	super.createChildren( self )

	local close = CustomButton {
		parent = self,
		pos = { 0, 0 },
		size = HP_BUTTON_CLOSE_SIZE,
		text = "<red>关闭</>",
		}

	close:addEventListener( Event.CLICK, M.onClickClose, self )
	self._close = close

	self:close()
end

function M:dispose()
	self:stopOpenAnim()
	self:_destoryPage()

	super.dispose( self )
end

function M:resizeHandler( e )
	-- 调整关闭按钮位置
	local close = self._close
	local pw, _ = self:getSize()
	local _, top, right, _ = unpack( PADDING )
	close:setPos( pw - right - HP_BUTTON_CLOSE_OFFSET, top - HP_BUTTON_CLOSE_OFFSET )

	return super.resizeHandler( self, e )
end

function M:setPage( pageClass )
	self._pageClass = pageClass
end

function M:_destoryPage()
	if self._page then
		self:removeChild( self._page )
		self._page:dispose()
		self._page = nil
	end
end

function M:_createPage()
	self:_destoryPage()

	local pageClass = self._pageClass
	if not pageClass or type( pageClass ) ~= "table" then return end

	local page = pageClass { parent = self, size = { 600, 400 } }
	page:onCreate()
	self._page = page

	if page then
		local w, h = page:getSize()
		local left, top, right, bottom = unpack( PADDING )
		local pw, ph = left + w + right, top + h + bottom

		self:setSize( pw, ph )
		self._x, self._y = math.even( ( gScreenWidth - pw ) / 2 ), math.even( ( gScreenHeight - ph ) / 2 )
		self:setPos( self._x, self._y )


		page:setPos( left, top )
	end
end

function M:onClickClose( e )
	gDialog.fShowTip( "click close" )

	self:close()
end

function M:open()
	if self:getVisible() == true then return end

	self:show()

	if not self._page then
		self:_createPage()
	end
	if self._page then
		self._page:show()
	end

	-- 创建打开动画
	self:playOpenAnim( function() 
			if self._page then self._page:enter() end
		end )
end

function M:close()
	if self:getVisible() == false then return end

	self:stopOpenAnim()

	if self._page then
		self._page:leave()
		self._page:hide()
	end

	self:hide()
end

function M:playOpenAnim( callback )
	self:stopOpenAnim()

	local duration = 0.3
	local x, y = self._x, self._y
	local anim = Animation():parallel(
		Animation( self ):fadeIn( duration, Ease.ein ),
		Animation( self ):setLoc( x, y + 30, 0 ):seekLoc( x, y, 0, duration, Ease.ein )
		)
	anim:play( { onComplete = callback } )

	self.openAnim = anim
end

function M:stopOpenAnim()
	if self.openAnim then
		self.openAnim:stop()
		self.openAnim = nil
	end
end


return M