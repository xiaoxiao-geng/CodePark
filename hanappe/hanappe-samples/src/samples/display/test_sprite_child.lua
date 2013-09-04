module(..., package.seeall)

function onCreate(params)
    layer = Layer {scene = scene, touchEnabled = true }

	frame = Sprite { texture = "card2.png", layer = layer, pos = { 0, 0 } }
	bird1 = Sprite { texture = "bird1.png", layer = layer, pos = { 0, 0 } }

	local fw, fh = frame:getSize()

	group = Group { size = { fw, fh } }
	group:setCenterPiv()

	group:addChild( frame )
	group:addChild( bird1 )

	print("onCreate")
	print("  group.pos:", group:getPos() )
	print("  group.loc:", group:getLoc() )
end

function onStart()
	print("onStart")
	group:seekLoc( 300, 300, 0, 5 )
	group:seekRot( 0, 0, 360, 5 )

	bird1:seekRot( 0, 0, -360, 5 )
end