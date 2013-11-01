module( ..., package.seeall )

local function extTheme()
	local themeExt = require( "hpExt/hpThemeExt" )
	local ThemeManager = require( "hp/manager/ThemeManager" )

	ThemeManager:addUserTheme( themeExt )
end

function onCreate()
	-- extTheme()

	view = View { scene = scene }

	panel1 = Panel { 
		parent = view, 
		size = { 200, 200 }, 
		pos = { 100, 100 }, 
        layout = VBoxLayout {
            align = { "center", "top" },
            padding = {10, 10, 10, 10},
            gap = {10, 10},
        	},
		}

	for i = 1, 10 do
		local panel = Panel {
			parent = panel1,
			size = { 180, 20 },
			color = { i * 0.2, 1, 1, 1 },
			}
	end
end