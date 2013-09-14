module( ..., package.seeall )

function onCreate( params )
	local view = View { scene = scene }

	local view1 = View { scene = scene, layerPriority = 900 }
	view1:getLayer().name = "Layer1"


	local view2 = View { scene = scene, layerPriority = 800 }
	view2:getLayer().name = "Layer2"

	local button1 = Button { parent = view1, pos = { 100, 100 }, text = "view1" }
	local button2 = Button { parent = view2, pos = { 200, 110 }, text = "view2" }
end