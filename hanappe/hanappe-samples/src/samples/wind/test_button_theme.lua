module( ..., package.seeall )

function onCreate( params )
	view = View { scene = scene }

	panel = Panel { parent = view, pos = { 50, 50 }, size = { 200, 200 } }

	panel:setClipPadding( 6, 8, 6, 8 )

	scroller = Scroller { 
		parent = panel, 
		hScrollEnabled = false,
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

	barX, barY, barW, barH = 180, 30, 7, 140
	bar1 = NinePatch { parent = panel, texture = "scrollerBar.png", pos = { barX, barY }, size = { barW, barH }, color = { 0, 0, 0, 0.5 } }
	-- bar2 = NinePatch { parent = view, texture = "scrollerBar.png", pos = { 200, 300 }, color = { 0, 0, 0, 0.5 } }
end

local r = 0
function onEnterFrame()
	local x, y = scroller:getPos()
	local w, h = scroller:getSize()
	print( "scroller -> ", x, y, w, h )

	local pw, ph = panel:getSize()

	local height = math.floor( ( ph / h ) * barH )

	local ah = h - ph
	local alphaY = -y / ah

	local by = math.floor( alphaY * ( barH - height ) ) + height * 0.5

	print( "h, alphaY", height, alphaY)

	bar1:setSize( barW, height )
	bar1:setPos( barX, by )
end