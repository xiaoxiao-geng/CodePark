local DEFAULT_TEXT_STYLE_NAME = "default"


--------------------------------------------------------------------------------
-- 底层模块
--------------------------------------------------------------------------------

-- 扩展math
local function fExtendMath()
	math.even = function( n )
		return math.floor( n * 0.5 ) * 2
	end
end

-- 扩展theme
local function fExtendTheme()
	local themeExt = require( "hpExt/hpThemeExt" )
	local ThemeManager = require( "hp/manager/ThemeManager" )

	ThemeManager:addUserTheme( themeExt )
end

local function fExtendTextureManager()
	local TextureManager = require( "hp/manager/TextureManager" )

	local _request = TextureManager.request
	TextureManager.request = function( self, path )
		return _request( self, RESOURCES.getPath( path ) )
	end
end

local function fExtendTouchProcessor()

end















--------------------------------------------------------------------------------
-- GUI控件
--------------------------------------------------------------------------------

local function fExtendComponent()
	local Component = require "hp/gui/Component"

	Component.setBoundsExt = function( self, left, top, right, bottom )
		self._extBounds = { left, top, right, bottom }

		if not self._extBoundGraphics then
			local graphics = Graphics { parent = self }

			local w, h = self:getSize()
			graphics:setPos( -left, -top )
			graphics:setSize( w + right * 2, h + bottom * 2 )

			self._extBoundGraphics = graphics
		end
	end

	local _resizeHandler = Component.resizeHandler
	Component.resizeHandler = function( self, e )
		if self._extBoundGraphics then
			local left, top, right, bottom = unpack( self._extBounds )
			local w, h = self:getSize()
			self._extBoundGraphics:setSize( -left, -top, w + right, h + bottom )
		end

		return _resizeHandler( self, e )
	end
end

local function fExtendView()
	local View = require( "hp/gui/View")

	local _setTouchEnabled = View.setTouchEnabled
	View.setTouchEnabled = function( self, value )
		_setTouchEnabled( self, value )

	    local layer = self:getLayer()
	    if layer then layer:setTouchEnabled( value ) end
	end

	View.setLayerPriority = function( self, value )
	    self._layerPriority = value

	    local layer = self:getLayer()
	    if layer then
	        layer:setPriority( value )
	    end
	end

	local _initLayer = View.initLayer
	View.initLayer = function( self )
		_initLayer( self )
		
	    if self._layerPriority then
	        layer:setPriority( self._layerPriority )
	    end
	end

	local _show = View.show
	View.show = function( self )
		_show( self )
		self:setTouchEnabled( true )
	end

	local _hide = View.hide
	View.hide = function( self )
		_hide( self )
		self:setTouchEnabled( false )
	end

	View.isView = function() return true end

	local _dispose = View.dispose
	View.dispose = function( self )
		self:setScene( nil )
		_dispose( self )
	end
end

local function fExtendPanel()
	local Panel = require( "hp/gui/Panel" )

	Panel.EVENT_TOUCH_DOWN = "panelTouchDown"
	Panel.EVENT_TOUCH_UP = "panelTouchUp"
	Panel.EVENT_TOUCH_MOVE = "panelTouchMove"
	Panel.EVENT_TOUCH_CANCEL = "panelTouchCancel"

	Panel.touchDownHandler = function( self, e ) 
		e:stop()
		self:dispatchEvent( Panel.EVENT_TOUCH_DOWN )
	end

	Panel.touchUpHandler = function( self, e ) 
		e:stop() 
		self:dispatchEvent( Panel.EVENT_TOUCH_UP )
	end

	Panel.touchMoveHandler = function( self, e )
		e:stop() 
		self:dispatchEvent( Panel.EVENT_TOUCH_MOVE )
	end
		
	Panel.touchCancelHandler = function( self, e ) 
		e:stop() 
		self:dispatchEvent( Panel.EVENT_TOUCH_UP )
	end
		

	-- 面板默认GroupId
	Panel.getPanelGroupId = function( self )
		if self._panelGroupId == nil then
			self._panelGroupId = RadioButtonManager.generalPanelGroupId()
		end
		return self._panelGroupId
	end
end

local function fExtendTextLabel()
	local TextLabel = require( "hp/display/TextLabel" )

	TextLabel.create = function( params )
		-- 预处理params，拦截style字段
		local style = params.style or DEFAULT_TEXT_STYLE_NAME
		params.style = nil

		local label = TextLabel( params )
		
		label:setTextStyle( style )

		-- 默认为开启自动换行
		label:setWordBreak( MOAITextBox.WORD_BREAK_CHAR )

		return label
	end

	TextLabel.setTextStyle = function( self, style )
	    if not style then return end
	    
		if type( style ) == "string" then
			style = gTextStyles.get( style )
		end

	    self:setStyle( style )
	    if style.isBmFont then
	        self:setShader ( MOAIShaderMgr.getShader ( MOAIShaderMgr.DECK2D_SHADER ))
	    else
	        self:setShader ( MOAIShaderMgr.getShader ( MOAIShaderMgr.FONT_SHADER ))
	    end
	end
end

local function fExtendButton()
	local Button = require( "hp/gui/Button" )

	local _updateDisplay = Button.updateDisplay
	Button.updateDisplay = function( self )
		local background = self._background
		background:setColor(unpack(self:getStyle("skinColor")))
		background:setTexture(self:getStyle("skin"))

		local label = self._label
		label:setTextStyle(self:getStyle("style"))
		label:setColor(unpack(self:getStyle("textColor")))

		if not self._skinResizable then
		local tw, th = background.texture:getSize()
			self:setSize(tw, th)
		end
	end
end

local function fExtendScroller()
	local Scroller = require( "hp/gui/Scroller" )

	-- 设置updateScroll回调
	Scroller.setOnUpdateScrollCallback = function( self, callback )
		self.fOnUpdateScrollCallback = callback
	end

	-- 拦截updateScroll方法，在正常流程执行完毕后执行回调
	local _updateScroll = Scroller.updateScroll
	Scroller.updateScroll = function( self )
		_updateScroll( self )

		local callback = self.fOnUpdateScrollCallback
		if callback and type( callback ) == "function" then callback( self ) end
	end

	local _setParent = Scroller.setParent
	Scroller.setParent = function( self, parent )
		_setParent( self, parent )

		if self._needFitEnable then
			self:fitEnable()
		end
	end

	Scroller.fitEnable = function( self )
		self._needFitEnable = true

		local parent = self:getParent()
		if parent and parent.getSize then
			self:updateLayout()

			local pw, ph = parent:getSize()
			local w, h = self:getSize()

			self:setHScrollEnabled( w > pw )
			self:setVScrollEnabled( h > ph )

			self._needFitEnable = false
		end
	end
end

local function fExtendDisplayObject()
	local DisplayObject = require( "hp/display/DisplayObject" )

	-- show & hide
	DisplayObject.show = function( self ) self:setVisible( true ) end
	DisplayObject.hide = function( self ) self:setVisible( false ) end

	DisplayObject.moveToFront = function( self )
		local parent = self:getParent()

		if parent and parent.isGroup then
			parent:removeChild( self )
			parent:addChild( self )
		end

		-- 找到view
		while true do
			if not parent then return end

			if parent.isView then
				parent:updateLayout()
				return
			end

			if not parent.getParent then return end

			parent = parent:getParent()
		end
	end

	-- 兼容gui中原有的接口
	DisplayObject.getDim = function( self )
		return self:getSize()
	end
end

local function fExtendSceneManager()
	local SceneManager = require( "hp/manager/SceneManager" )

	SceneManager.setUltraliskLayers = function( self, layers )
		if not layers or type( layers ) ~= "table" then layers = {} end

		for k, layer in ipairs( layers ) do
			self:removeBackgroundLayer( layer )
			self:addBackgroundLayer( layer )
		end

		self:updateRender()
	end
end

local function fExtendLayer()
	local Layer = require( "hp/display/Layer")
end











local function fLoadModules()
	_G.table 				= require "hp/lang/table"

	_G.Ease 				= require "hpExt/EaseType"

	_G.RadioButtonManager 	= require "hpExt/component/RadioButtonManager"
	_G.RadioButton 			= require "hpExt/component/RadioButton"
	_G.RadioButtonGroup 	= require "hpExt/component/RadioButtonGroup"

	_G.TextureTextButton 	= require "hpExt/component/TextureTextButton"

	_G.ListPanel 			= require "hpExt/component/ListPanel"
	_G.CustomButton 		= require "hpExt/component/CustomButton"
	_G.EditBox 				= require "hpExt/component/EditBox"
	_G.HBoxLayoutComponent 	= require "hpExt/component/HBoxLayoutComponent"
	_G.VBoxLayoutComponent 	= require "hpExt/component/VBoxLayoutComponent"

	_G.ProgressBar 			= require "hpExt/component/ProgressBar"

	-- 自定义控件（模块控件）
	_G.ItemIcon   			= require "play/ui/module/item/cItemIcon"
	_G.ItemButton   		= require "play/ui/module/item/cItemButton"
	_G.ItemShowBox   		= require "play/ui/module/item/cItemShowBox"
	_G.ItemStar   			= require "play/ui/module/item/cItemStar"

	_G.ForgeLabel 			= require "play/ui/module/forge/cForgeLabel"
	_G.ForgeRemakeLabel		= require "play/ui/module/forge/cForgeRemakeLabel"

	_G.SkillButton   		= require "play/ui/module/skill/cSkillButton"
	_G.SkillRuneButton   	= require "play/ui/module/skill/cSkillRuneButton"
	_G.ShortcutsButton 		= require "play/ui/hud/shortcuts/cShortcutsButton"
	_G.MessageTipLabel 		= require "play/ui/hud/tip/cMessageTipLabel"

	_G.gHpLayoutParser 		= require "hpExt/hpLayoutParser"
end

function gfExtendHpFramework()
	fExtendMath()

	-- 底层
	fExtendTextureManager()
	fExtendDisplayObject()

	-- Display层
	fExtendSceneManager()
	fExtendLayer()

	-- Gui层
	fExtendComponent()
	fExtendView()
	fExtendPanel()
	fExtendTextLabel()
	fExtendButton()
	fExtendScroller()

	require ( "state/modules" )
	
	fExtendTheme()

	fLoadModules()
end

gfExtendHpFramework()


-- 提供各种扩展方法
function gfCreateView( order, fOnDestory, name )
	local Scene = require("hp/display/Scene")
	local scene = SceneManager:getCurrentScene()
	local view = View { name = name, scene = scene, layerPriority = order }

	if fOnDestory and type( fOnDestory ) == "function" then
		scene:addEventListener( Scene.EVENT_DESTROY, fOnDestory )
	end

	return view
end