module( ..., package.seeall )

MyButton = {
    normal = {
        skin = "skins/button-normal.png",
        skinClass = Sprite,
        skinColor = {1, 0, 0, 1},
        font = "VL-PGothic",
        textSize = 24,
        textColor = {0.0, 0.0, 0.0, 1},
        textPadding = {10, 5, 10, 8},
    },
    selected = {
        skin = "skins/button-selected.png",
    },
    over = {
        skin = "skins/button-over.png",
    },
    disabled = {
        skin = "skins/button-disabled.png",
        textColor = {0.5, 0.5, 0.5, 1},
    },
}

function onCreate( params )
    -- local themeExt = require( "hpExt/hpThemeExt" )
    local ThemeManager = require( "hp/manager/ThemeManager" )

    local theme = ThemeManager:getTheme()

    theme[ "MyButton" ] = MyButton

    ThemeManager:setTheme( theme )












	layer = Layer { scene = scene, touchEnabled = true }

	view = View { scene = scene }
	scroller = Scroller { 
		parent = view, 
		layout = HBoxLayout {
                align = {"center", "center"},
                padding = {10, 10, 10, 10},
            }
        }

    local buttons = {}
    for i = 1, 1 do
		local button = Button { parent = scroller, size = { 200, 200 }, text = "hello" .. i, themeName = "MyButton" }
		-- button:setTheme( theme )
		local sprite = Sprite { parent = button, pos = { 0, 0 }, texture = "bird" .. i .. ".png" }
		table.insert( buttons, button )
    end

    Sprite { parent = view, pos = { 0, 0 }, texture = "bird5.png" }

    -- for k, v in pairs( buttons ) do
    -- 	v:recreateChildren()
    -- end
end

