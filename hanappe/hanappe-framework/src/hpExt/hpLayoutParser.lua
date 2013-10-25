local utilities 	= require "gui/support/utilities"
local table         = require "hp/lang/table"
local Component 	= require "hp/gui/Component"

local DEFAULT_PADDING = { 8, 8, 8, 8 }
local DEFAULT_SPACING = { 4, 4 }

Direction = {
	left 		= 1,
	top 		= 2,
	center 		= 3,
	right 		= 4,
	bottom 		= 5,

	leftTop 	= 6,
	leftBottom 	= 7,
	rightTop 	= 8,
	rightBottom = 9,
}

Direction.isTop = function( dir ) return dir == Direction.leftTop or dir == Direction.top or dir == Direction.rightTop end
Direction.isBottom = function( dir ) return dir == Direction.leftBottom or dir == Direction.top or dir == Direction.rightBottom end

Direction.isLeft = function( dir ) return dir == Direction.leftTop or dir == Direction.left or dir == Direction.leftBottom end
Direction.isRight = function( dir ) return dir == Direction.rightTop or dir == Direction.right or dir == Direction.rightBottom end

Direction.isHCenter = function( dir ) return dir == Direction.left or dir == Direction.center or dir == Direction.right end
Direction.isVCenter = function( dir ) return dir == Direction.top or dir == Direction.center or dir == Direction.bottom end

local M = {}

local constructors = {
	panel			= Panel,
	button			= CustomButton,
	editBox			= EditBox,
	radioButton		= RadioButton,
	radioGroup		= RadioButtonGroup,
	label			= TextLabel.create,
	group			= Group,
	sprite			= Sprite,
	scroller		= Scroller,
	component		= Component,
	hLayout			= HBoxLayoutComponent,
	vLayout			= VBoxLayoutComponent,
	listPanel		= ListPanel,
	
	progressBar		= ProgressBar,
	
	itemButton		= ItemButton,
	itemIcon		= ItemIcon,
	itemStar 		= ItemStar,

	longButton 		= TextureTextButton.LongButton,
	shortButton 	= TextureTextButton.ShortButton,
	
	skillButton		= SkillButton,
	skillRuneButton	= SkillRuneButton,
	shortcutsButton	= ShortcutsButton,
}

local noSizeComponents = {
	radioGroup 	= true,
	component 	= true,
	listPanel 	= true,
}

local fixedSizeComponent = {
	skillButton		= SkillButton.getSize,
	skillRuneButton	= SkillRuneButton.getSize,
	shortcutsButton	= ShortcutsButton.getSize,
	
	itemButton		= ItemButton.getSize,
	itemIcon		= ItemIcon.getSize,
	itemStar 		= ItemStar.getSize,

	longButton 		= TextureTextButton.LongButton.getSize,
	shortButton 	= TextureTextButton.ShortButton.getSize,
}

local layoutConstructors = {
	vbox 		= VBoxLayout,
	hbox 		= HBoxLayout,
}

local needPadSpace = {
	hLayout 	= true,
	vLayout 	= true,
}
local _G_const_backup = {}
local isConstInjected = false

local function isString( value ) return value and type( value ) == "string" end
local function isTable( value ) return value and type( value ) == "table" end
local function isFunction( value ) return value and type( value ) == "function" end

local function injectConsts()
	if isConstInjected then return end
	isConstInjected = true

	-- 1. 备份全局变量
	local backup = {}
	for k, v in pairs( Direction ) do backup[ k ] = _G[ k ] end
	_G_const_backup = backup

	-- 注入
	for k, v in pairs( Direction ) do _G[ k ] = v end
end

local function backConsts()
	if not isConstInjected then return end
	isConstInjected = false

	-- 归还备份的全局变量
	for k, v in pairs( _G_const_backup ) do
		_G[ k ] = v
	end
end

local function parsePadding( value )
	if not value then return nil end

	if type( value ) == "number" then return { value, value, value, value }
	elseif type( value ) == "table" then return value end

	error( "wrong padding value:" .. tostring( value ) )
end

local function parseSpacing( value )
	if not value then return nil end

	if type( value ) == "number" then return { value, value }
	elseif type( value ) == "table" then return value end

	error( "wrong spacing value:" .. tostring( value ) )
end

local function parseDirection( value )
	if not value then return nil end

	if type( value ) == "number" then return value
	elseif type( value ) == "string" then
		local direction = Direction[ value ]



		if not direction then
			error( "wrong direction value: " .. tostring( value ) )
		end

		assert( direction, "wrong direction value: " .. tostring( value ) )


		return direction
	end

	error( "wrong direction value: " .. tostring( value ) )
end

local function parseRelative( value )
	if not value then return nil end

	if type( value ) == "table" then
		local targetName = value[ 1 ]
		local direction = parseDirection( value[ 2 ] )
		local align = parseDirection( value[ 3 ] )

		if not targetName or targetName == "" or not direction or not align then
			error( "wrong relative value: " .. tostring( targetName ) .. ", " .. tostring( direction ) .. ", " .. tostring( align ) )
		end
		return { targetName, direction, align }
	end

	error( "wrong relative value: " .. tostring( value ) )
end

local function parseSize( value, parent, parentconfig, widgets )
	if not value then return nil end

	if type( value ) == "table" then 
		local w, h = unpack( value )
		if w == "fill-parent" then
			if not parent then error( "wrong size! parent not fount! " .. tostring( sx ) .. ", " .. tostring( sy ) ) end
			local pw, _ = parent:getSize()
			w = pw - parentconfig.padding[1] - parentconfig.padding[3]
		elseif w == "full-screen" then w = gScreenWidth end

		if h == "fill-parent" then
			if not parent then error( "wrong size! parent not fount! " .. tostring( sx ) .. ", " .. tostring( sy ) ) end
			local _, ph = parent:getSize()
			h = ph - parentconfig.padding[2] - parentconfig.padding[4]
		elseif h == "full-screen" then h = gScreenHeight end

		return { w, h }

	elseif type( value ) == "string" then
		local widget = widgets[ value ]
		if not widget or not widget.getSize then
			error( "wrong size target widget! miss or not a widget: " .. tostring( value ) )
		end
		local w, h = widget:getSize()
		return { w, h }
	end

	error( "wrong size value: " .. tostring( value ) )
end

local function getAnchor( data, parent, config )
	local left, top, right, bottom = 0, 0, 0, 0
	local w, h = unpack( data.size )
	local anchor = data.anchor

	local pw, ph = 0, 0
	if parent then 
		pw, ph = parent:getSize()
		left, top, right, bottom = unpack( config.padding )
	else 
		pw, ph = gScreenWidth, gScreenHeight 
	end

	-- x
	if anchor == Direction.leftTop or anchor == Direction.left or anchor == Direction.leftBottom then
		x = left
	elseif anchor == Direction.top or anchor == Direction.center or anchor == Direction.bottom then
		x = math.floor( ( pw - w ) * 0.5 ) 
	else
		x = pw - w - right
	end 

	-- y
	if anchor == Direction.leftTop or anchor == Direction.top or anchor == Direction.rightTop then
		y = top
	elseif anchor == Direction.left or anchor == Direction.center or anchor == Direction.right then
		y = math.floor( ( ph - h ) * 0.5 ) 
	else
		y = ph - h - bottom
	end 

	return x, y
end

local function getRelativePos( data, widgets, config )
	local targetName, direction, align = unpack( data.relative )
	local hspace, vspace = unpack( config.spacing )

	local target = widgets[ targetName ]
	if not target then error( "wrong relative, target not found! :" .. tostring( targetName ) .. ", " .. tostring( direction ) .. ", " .. tostring( align ) ) end

	local tleft, ttop, tright, tbottom = target:getLeft(), target:getTop(), target:getRight(), target:getBottom()
	local tw, th = target:getSize()
	local w, h = unpack( data.size )
	local x, y = 0, 0

	-- 1. 处理方向
	-- 2. 处理对齐
	if direction == Direction.left then
		-- 在目标左边
		x = tleft - w - hspace
		if align == Direction.top then			y = ttop
		elseif align == Direction.bottom then	y = tbottom - h
		else 									y = ttop + math.floor( ( th - h ) * 0.5 )
		end

	elseif direction == Direction.top then
		-- 在目标上面
		y = ttop - h - vspace
		if align == Direction.left then 		x = tleft
		elseif align == Direction.right then	x = tright - w
		else 									x = tleft + math.floor( ( tw - w ) * 0.5 )
		end

	elseif direction == Direction.right then
		-- 在目标右边
		x = tright + hspace
		if align == Direction.top then			y = ttop
		elseif align == Direction.bottom then	y = tbottom - h
		else 									y = ttop + math.floor( ( th - h ) * 0.5 )
		end

	else
		-- 在目标下面
		y = tbottom + vspace
		if align == Direction.left then 		x = tleft
		elseif align == Direction.right then	x = tright - w
		else 									x = tleft + math.floor( ( tw - w ) * 0.5 )
		end

	end 

	return x, y
end

local function getTextureSize( textureName )
	local texture = nil
    if type( textureName ) == "string" then
        texture = TextureManager:request( textureName )
    end
    if not texture or not texture.getSize then
    	error( "wrong texture, texture not fount! :" .. tostring( textureName ))
    end

    return texture:getSize()
end















-- layout解析器
function M.loadLayout( fileName, parent )
	injectConsts()

	if fileName and type( fileName ) == "string" then
		local data = utilities.loadFileData( RESOURCES.getPath( fileName ) )

		if not data or type( data ) ~= "table" then
			error( "wrong layout file! data not found: " .. tostring( fileName ) )
		end

		if #data > 1 then
			gLog.warn( "layout has mutil root!", fileName )
		end

		return M.loadLayoutFromData( data, parent )
	end

	backConsts()

	return {}
end

function M.loadLayoutFromData( data, parent )
	-- 递归解析
	local widgets = {}
	local root = nil

	for k, v in pairs( data ) do
		local widget = M.parseData( v, widgets, parent, { padding = {0,0,0,0}, spacing = {0,0} } )
		if not root then root = widget end
	end

	return root, widgets
end

-- 传入的data已经是一个具体控件
function M.parseData( data, widgets, parent, _config )
	local config = table.copy( _config or {} )
	config.padding = config.padding or DEFAULT_PADDING
	config.spacing = config.spacing or DEFAULT_SPACING

	-- 1. 提取 name, widget, children
	local name = data.name or ""

	local widgetName = data.widget
	data.widget = nil

	local constructor = constructors[ widgetName ]
	if not constructor then
		error( "wrong miss constructor! type:" .. tostring( widgetName )  )
	end

	local children = data.children
	data.children = nil

	local call = data.call or {}
	data.call = nil

	local afterCall = data.afterCall or {}
	data.afterCall = nil

	local layout = data.layout
	data.layout = nil

	local clip = data.clip
	data.clip = nil

	-- 针对带有texture字段没有size的字段的情况
	-- 提取texture的size作为控件尺寸
	if not data.size and data.texture then
		data.size = { getTextureSize( data.texture ) }
	end

	data.size = parseSize( data.size, parent, config, widgets ) or { 0, 0 }
	if fixedSizeComponent[ widgetName ] then
		local fGetSize = fixedSizeComponent[ widgetName ] 
		if isFunction( fGetSize ) then
			data.size = { fGetSize() }
		else
			error( "wrong fixedSize: " .. widgetName )
		end
	end

	-- 检查size
	if not noSizeComponents[ widgetName ] then
		if data.size[1] == 0 and data.size[2] == 0 then
			error( "wrong size value! must has size: " .. tostring( widgetName ) .. " - " .. tostring( name ) )
		end
	end

	data.pos = data.pos or { 0, 0 }

	data.parent = parent

	-- 2. 预处理配置
	data.padding = parsePadding( data.padding )
	data.spacing = parseSpacing( data.spacing )
	data.anchor = parseDirection( data.anchor ) or Direction.leftTop
	data.relative = parseRelative( data.relative )

	-- print("parse ->", name, widgetName)
	-- print("  pos", unpack( data.pos ) )
	-- print("  size", unpack( data.size ) )
	-- print("  padding", data.padding and unpack( data.padding ) )
	-- print("  spacing", data.spacing and unpack( data.spacing ) )
	-- print("  anchor", data.anchor )
	-- print("  relative", data.relative and unpack( data.relative ) )

	-- 3. 对齐处理
	if data.relative then
		-- 处理相对对齐
		local x, y = getRelativePos( data, widgets, config )
		local dx, dy = unpack( data.pos )
		data.pos = { dx + x, dy + y }

	elseif data.anchor then
		-- 处理锚点对齐
		local x, y = getAnchor( data, parent, config )
		local dx, dy = unpack( data.pos )
		data.pos = { dx + x, dy + y }
	end

	-- 4. 处理布局
	if isTable( layout ) then
		local type = layout.type
		local constructor = layoutConstructors[ type ]
		local padding = parsePadding( layout.padding ) or { 0, 0, 0, 0 }
		local spacing = parseSpacing( layout.spacing ) or { 0, 0 }
		local align = layout.align or { "left", "top" }
		if constructor and padding and spacing then
			-- print("  createLayout" )
			-- print("    align", unpack( align ) )
			-- print("    padding", unpack( padding ) )
			-- print("    spacing", unpack( spacing ) )
			data.layout = constructor { align = align, padding = padding, gap = spacing }
		end
	end

	-- 5. 处理配置	
	if data.padding then config.padding = data.padding end
	if data.spacing then config.spacing = data.spacing end

	-- 特殊处理需要padding和spacing字段的组件
	if not needPadSpace[ widgetName ] then
		data.padding = nil
		data.spacing = nil
	end
	data.anchor = nil
	data.relative = nil

	-- 6. 解析自身
	local widget = constructor( data )
	if not widget then
		error( "constructor widget is nil!" )
	end

	widgets[ name ] = widget

	-- 7.执行call
	if isString( call ) then call = { call } end
	for k, v in pairs( call ) do
		local func = widget[ v ]
		if isFunction( func ) then func( widget ) end
	end

	-- 8. 解析children
	if children and isTable( children ) then
		for k, childData in pairs( children ) do
			local child = M.parseData( childData, widgets, widget, config )
			-- child:setParent( widget )
		end
	end

	-- 9.执行 后续任务 afterCall
	if isString( afterCall ) then afterCall = { afterCall } end
	for k, v in pairs( afterCall ) do
		local func = widget[ v ]
		if isFunction( func ) then func( widget ) end
	end

	if clip then
		if isTable( clip ) then widget:setClipPadding( unpack( clip ) )
		else widget:setClipPadding( clip ) end
	end

	return widget
end

return M