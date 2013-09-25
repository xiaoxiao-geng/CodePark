module( ..., package.seeall )

function onCreate( params )
	local layer = Layer { scene = scene, touchEnabled = true }

	local view = View { scene = scene }

	-- local view1 = View { scene = scene, layerPriority = 900 }
	-- view1:getLayer().name = "Layer1"


	-- local view2 = View { scene = scene, layerPriority = 800 }
	-- view2:getLayer().name = "Layer2"

	-- local button1 = Button { parent = view, pos = { 100, 100 }, text = "view1" }

	-- local group = Group { parent = view }

	-- local la
	local sprite1 = Sprite { layer = layer, pos = { 200, 200 }, texture = "bird1.png" }
	-- local sprite2 = Sprite { layer = layer, parent = sprite1, texture = "bird2.png" }
	local label = TextLabel { layer = layer, parent = sprite1, text = "hello", size = { 200, 200 } }

	-- sprite2._parent = sprite1

	sprite1:addEventListener( "touchDown", function() 
		print("touch 1")
		end )

	-- sprite2:addEventListener( "touchDown", function() 
	-- 	print("touch 2")
	-- 	end )

	-- Animation( group, 5 ):seekLoc( 200, 200, 0 ):seekLoc( 100, 100, 0 ):play()

	-- local button2 = Button { parent = view2, pos = { 200, 110 }, text = "view2" }
end