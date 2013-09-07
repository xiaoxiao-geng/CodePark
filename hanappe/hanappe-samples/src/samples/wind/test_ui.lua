module( ..., package.seeall )

local g9Button = {
    normal = {
        skin = "button-g9-normal.png",
        skinClass = NinePatch,
        skinColor = {1, 1, 1, 1},
        font = "VL-PGothic",
        textSize = 18,
        textColor = {0.0, 0.0, 0.0, 1},
        textPadding = {10, 5, 10, 8},
    },
    selected = {
        skinColor = {1, 1, 0, 1},
        textColor = {1, 0, 0, 1},
    },
    over = {
        -- skin = "skins/button-over.png",
    },
    disabled = {
        -- skin = "skins/button-disabled.png",
        skinColor = {0.5, 0.5, 0.5, 1},
        textColor = {0.5, 0.5, 0.5, 1},
    },
}

function onCreate( params )
    -- 设置主题
    local ThemeManager = require "hp/manager/ThemeManager"
    local theme = ThemeManager:getTheme()
    theme.g9Button = g9Button
    ThemeManager:setTheme( theme )

	layer = Layer { scene = scene, touchEnabled = true }

	button1 = Button {
			layer = layer,
			pos = { 100, 100 },
            size = { 120, 70 },
			text = "button1",
            onClick = onButtonClick,
            themeName = "g9Button",
		}

    button2 = Button {
            layer = layer,
            pos = { 100, 200 },
            size = { 120, 200 },
            text = "button2",
            onClick = onButtonClick,
            themeName = "g9Button",
        }

    print("button1", button1)
    print("button2", button2)

    selectedFrame = NinePatch { color = {1,0,0,1}, texture = "button-selected.png", layer = layer, pos = { 300, 300 }, size = { 100, 100 } }



    buttonEnable = Button { layer = layer, pos = { 300, 100 }, text = "Enabled", 
        onClick = function()
            button1:setEnabled( true )
        end }

    buttonDisable = Button { layer = layer, pos = { 300, 200 }, text = "Disabled", 
        onClick = function()
            button1:setEnabled( false )
        end }



	-- -- 自定义button
	-- buttonHello:setTheme( btnTheme )
end

function onButtonClick( e )
    local button = e.target
    if not button then return end

    print( "onButtonClick", button )

    local parent = button:getParent()
    selectedFrame:setParent( parent )

    print( "  size", button:getSize() )
    print( "  pos", button:getPos() )

    selectedFrame:setSize( button:getSize() )
    selectedFrame:setPos( button:getPos() )

end