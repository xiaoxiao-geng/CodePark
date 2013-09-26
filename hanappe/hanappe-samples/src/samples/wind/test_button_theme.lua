module( ..., package.seeall )

function onCreate( params )
	view = View { scene = scene }

	panel = Panel { parent = view, pos = { 50, 50 }, size = { 200, 200 } }

	scroller = Scroller { 
		parent = panel, 
		layout = VBoxLayout {
	        align = {"center", "top"},
	        padding = {10, 10, 10, 10},
	        gap = {10, 10},
	    },
	}

	for i = 1, 10 do
		local btn = Button { parent = scroller, text = "text" .. i }
	end

	-- panel:setClip()

	button = Button { parent = view, text = "random" }
	button:addEventListener( "click", function() 
			count = math.random( 1, 10 )
			scroller:removeChildren()
			scroller:setPos( 0, 0 )
			for i = 1, count do
				local btn = Button { parent = scroller, text = "text" .. i }
			end
			scroller:updateLayout()
			print("size", scroller:getSize() )
			print("children")
			for k, v in pairs( scroller.children ) do
				print("  ", k, v )
			end
		end )
end