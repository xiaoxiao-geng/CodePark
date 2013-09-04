module(..., package.seeall)

function onCreate( params )
	print(" () ()\n( @ @ )\n(  -  )    onCreate", params, unpack( params ) )

	layer = Layer { scene = scene }

	local temp = Sprite { texture = "cathead.png" }
	local w, h = temp:getSize()

	for x = 0, 2 do
		for y = 0, 2 do
			local id = x * 3 + y

			local sprite = Sprite { texture = "cathead.png", layer = layer }
			sprite:setLeft( x * w )
			sprite:setTop( y * h )

			local r = 0.2 + x * 0.4
			local g = 0.2 + y * 0.4
			local b = 0

			sprite:seekColor( r, g, b, 1, 0 )

			sprite.id = id

			sprite:addEventListener( "touchDown", onTouchDown )
		end
	end



end

function onTouchDown( e )
	local prop = e.touchingProp
	print("down", prop, prop and prop.id )
end