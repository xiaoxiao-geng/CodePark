-- TabControl

-- import
local table		= require "hp/lang/table"
local class		= require "hp/lang/class"
local Component	= require "hp/gui/Component"
local Page		= require "hpExt/container/Page"

-- class
local super		= Page
local M			= class( super )

function M:onCreate()
	self._pageClasses = self:getTabPageClasses()
	self._pages = {}
	self._currPage = nil

	self:setLayout( BoardLayout {
			padding = { 0, 0, 0, 0 },
			gap = { 0, 0 },
		} )
	
	-- 创建标签按钮
	local group = self:createRadioButtonGroup()

	self:updateLayout()

	local content = self:createComponentContent()

	-- 填充标签
	group:addEventListener( RadioButtonGroup.EVNET_SELECTED, M.onPageSelected, self )
	self:setGroupTitle( group )
	self.group = group
	self.content = content
end

function M:onDestory()
	self._pageClasses = {}
	if self._pages then
		for k, v in pairs( self._pages ) do
			v:dispose()
		end
		self._pages = {}
	end
end







--[[
	子类可以重写的部分
	RadioButton
		标签页对齐方式（BoardLayout）
		按钮尺寸、间距
		按钮样式、内容（文本、texture、textTexture）

	内容面板
		位置、尺寸 or BoardLayout布局方式
		clip参数

	动画
		当前页动画
		下一页动画
]]--
-- 提供子类覆写部分

-- 是否使用文字标题
function M:isUseTextTitle()
	return true
end

-- 创建标签页按钮组
function M:createRadioButtonGroup()
	local config = self:getRadioButtonGroupConfig()

	local params = { 
		parent = self,
		boardLayoutDirection = "top",
		buttonSize = HP_BUTTON_SIZE,
		buttonSpacing = HP_CONTENT_GAP_HORIZON,
		}

	for k, v in pairs( config ) do
		if v then params[ k ] = v end
	end

	return RadioButtonGroup( params )
end

-- 按钮组配置文件，由子类覆写
-- 各项属性均有默认值，只需配置需要修改的部分即可
function M:getRadioButtonGroupConfig()
	return { 
		buttonTheme = nil,
		boardLayoutDirection = nil,
		horizonAlign = "center",
		verticalAlign = nil,
		buttonSize = nil,
		buttonSpacing = nil,
		}
end

-- 创建填充page的内容面板
function M:createComponentContent()
	local config = self:getComponentContentConfig()

	local contentClass = config.contentClass or Panel
	config.contentClass = nil

	local params = {
		parent = self,
		clipPadding = HP_PANEL_CLIP,
		}

	for k, v in pairs( config ) do
		if v then params[ k ] = v end
	end

	return contentClass( params )
end

function M:getComponentContentConfig()
	return {
		contentClass = nil,
		pos = nil,
		size = nil,
		boardLayoutDirection = "center",
		clipPadding = nil
		}

end

-- 标签页进入动画
-- @param page 				播放动画的page
-- @param contentWidth 		内容面板宽度
-- @param isForward 		是否为正向    横版模式，正向为点击当前标签页右侧的标签
function M:creatPageEnterAnim( page, contentWidth, isForward )
	if not isForward then contentWidth = -contentWidth end
	return Animation( page ):setLoc( contentWidth, 0 ):seekLoc( 0, 0, 0, 0.3, Ease.ein )
end

-- 标签页离开动画
-- @param page 				播放动画的page
-- @param contentWidth 		内容面板宽度
-- @param isForward 		是否为正向    横版模式，正向为点击当前标签页右侧的标签
function M:creatPageLeaveAnim( page, contentWidth, isForward )
	if not isForward then contentWidth = -contentWidth end
	return Animation( page ):seekLoc( -contentWidth, 0, 0, 0.3, Ease.ein )
end











function M:onEnter()
	-- 如果没有当前页面，选中第一个
	-- 如果有，调用第一个的入口事件
	if self._currPage then
		self._currPage:enter()
	else
		self.group:setButtonActived( 1, true )
	end
end

function M:onLeave()
	if self._currPage then
		self._currPage:leave()
	end
end


-- 添加子page 使用class进行添加
-- 由children调用
function M:getTabPageClasses()
	return {}
end

function M:setGroupTitle( group )
	local titles = {}
	local useText = self:isUseTextTitle()

	for k, v in pairs( self._pageClasses ) do
		if v.getTitle then 
			local data = v.getTitle()
			local text, texture, textureName = data.text, data.texture, data.textureName

			if useText then
				table.insert( titles, text )
			else
				if textureName then
					texture = string.format( "ml/button/tab/%s.png", tostring( textureName ) )
				end
				table.insert( titles, texture )
			end
		end
	end

	if useText then
		group:setTexts( titles )
	else
		group:setTextures( titles )
	end
end

function M:getTabPageTitles()
	local titles = {}
	for k, v in pairs( self._pageClasses ) do
		if v.getTitle then
			table.insert( titles, v.getTitle() )
		end
	end
	return titles
end

function M:onPageSelected( e )
	local id = e.selectedId

	gDialog.fShowTip( "selected" .. id )

	local pages = self._pages
	local content = self.content
	local w, h = content:getSize()

	local isForward = true

	-- 1. 注销当前的page
	if self._currPage then
		local curr = self._currPage

		if curr.id < id then isForward = false end

		curr:leave()
		local anim = self:creatPageLeaveAnim( curr, w, isForward )
		if anim then
			curr:playPageAnimation( anim, function() 
					curr:hide() 
					content:removeChild( curr )
				end )
		else
			curr:hide() 
			content:removeChild( curr )
		end
	end

	-- 2. 提取当前id对应的page
	local page = pages[ id ]

	-- 3. 创建page
	if not page then
		pageClass = self._pageClasses[ id ]
		page = pageClass { 
			parent = content,
			size = { w, h },
			}
		page.id = id
		pages[ id ] = page

		page:onCreate()

	else
		content:addChild( page )
		page:setPos( 0, 0 )
	end



	-- 4. 显示选中的page
	self._currPage = page

	page:show()

	local anim = self:creatPageEnterAnim( page, w, isForward )
	if anim then
		page:playPageAnimation( anim, function() page:enter() end )
	else
		page:enter()
	end
end

return M