module(..., package.seeall)

function onCreate(params)
    layer = Layer {scene = scene, touchEnabled = true }

	frame = Sprite { texture = "card2.png", layer = layer, pos = { 0, 0 } }
	bird1 = Sprite { texture = "bird1.png", layer = layer, pos = { 0, 0 } }

	local fw, fh = frame:getSize()

	group = Group { size = { fw, fh } }
	group:setLoc( 100, 100 )
	group:setCenterPiv()

	group:addChild( frame )
	group:addChild( bird1 )

	print("onCreate")
	print("  group.pos:", group:getPos() )
	print("  group.loc:", group:getLoc() )


	groupAnim = Animation( group )
		:parallel(
			Animation( group ):seekLoc( 300, 300, 0, 5 ),
			Animation( group ):seekRot( 0, 0, 3600, 5 )
			)
		:wait( 2 )
		:seekScl( 0.5, 2, 2 )

	birdAnim = Animation( bird )
		:parallel(
			Animation( bird1 ):seekLoc( 240, 240, 0, 5 ),
			Animation( bird1 ):seekRot( 0, 0, -3600, 5 )
			)

	button = Button { text = "stop", }
end

function onStart()
	print("onStart")
	-- group:seekLoc( 300, 300, 0, 5 )
	-- group:seekRot( 0, 0, 360, 5 )

	-- bird1:seekRot( 0, 0, -360, 5 )
	groupAnim:play()
	birdAnim:play()
end