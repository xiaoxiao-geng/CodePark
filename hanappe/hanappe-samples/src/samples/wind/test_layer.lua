module( ..., package.seeall )

function onCreate( params )
	layer = Layer { scene = scene, touchEnabled = true }
	layer.name = "layer"

	layer1 = Layer { scene = scene, touchEnabled = true  }
	layer1.name = "layer1"

	layer2 = Layer { scene = scene, touchEnabled = true  }
	layer2.name = "layer2"

	Button { layer = layer, pos = { 500, 100 }, text = "1 to top", onClick = function( e ) 
		layer1:moveToFront()
	end }
	Button { layer = layer, pos = { 500, 200 }, text = "2 to top", onClick = function( e ) 
		layer2:moveToFront()
	end }

	sprite1 = Sprite { layer = layer1, texture = "bird1.png", pos = { 100, 100 } }
	sprite2 = Sprite { layer = layer2, texture = "bird2.png", pos = { 150, 150 } }

	layer1:setPos( -400, 0 )
	layer2:setPos( 400, 0 )
end

function onStart()
	Animation( { layer1, layer2 }, 3 ):seekLoc( 0, 0, 0 ):play()
	Animation( { layer1, layer2 }, 3 ):setColor( 0, 0, 0, 0 ):seekColor( 1, 1, 1, 1 ):play()
end