module( ..., package.seeall )

function onCreate( params )
	layer1 = Layer { scene = scene }
	layer2 = Layer { scene = scene }

	sprite1 = Sprite { layer = layer1, texture = "bird1.png", pos = { 100, 100 } }
	sprite2 = Sprite { layer = layer2, texture = "bird2.png", pos = { 150, 150 } }

	layer1:setPos( -400, 0 )
	layer2:setPos( 400, 0 )
end

function onStart()
	Animation( { layer1, layer2 }, 3 ):seekLoc( 0, 0, 0 ):play()
	Animation( { layer1, layer2 }, 3 ):setColor( 0, 0, 0, 0 ):seekColor( 1, 1, 1, 1 ):play()
end