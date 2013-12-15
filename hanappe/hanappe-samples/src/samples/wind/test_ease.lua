module( ..., package.seeall )


function onCreate()
	local view = View { scene = scene }

	sprites = {}
	eases = { 
		MOAIEaseType.EASE_IN,
		MOAIEaseType.EASE_OUT,
		MOAIEaseType.SMOOTH,
		MOAIEaseType.LINEAR,
		MOAIEaseType.SHARP_EASE_IN,
		MOAIEaseType.SHARP_EASE_OUT,
		MOAIEaseType.SHARP_SMOOTH,
		MOAIEaseType.SOFT_EASE_IN,
		MOAIEaseType.SOFT_EASE_OUT,
		MOAIEaseType.SOFT_SMOOTH,
		}

	texts = {
		"in", "out", "smooth", "lienar",
		"sp_in", "sp_out", "sp_smooth",
		"so_in", "so_out", "so_smooth",
		}

	for k, v in pairs( eases ) do
		sprites[ k ] = Sprite { parent = view, texture = "bird" .. ( k % 6 ) + 1 .. ".png", size = { 80, 80 } }

		TextLabel { parent = view, pos = { k * 80 - 80, 60 + ( k % 2 ) * 40 }, size = { 160, 40 }, align = { "center", "center" }, text = texts[ k ] }
	end

	anims = {}

	Button { parent = view, pos = { 50, 50 }, size = { 100, 50 }, text = "start", onClick = function() 
		for k, v in pairs( anims ) do v:stop() end

		for k, v in pairs( sprites ) do
			anims[k] = Animation():loop( -1, Animation( v ):
				setLoc( k * 80, 150, 0 ):
				seekLoc( k * 80, 450, 0, 1, eases[ k ] ):
				seekLoc( k * 80, 150, 0, 1, eases[ k + 1 ] )
				)
			anims[k]:play()
		end
		end }
end