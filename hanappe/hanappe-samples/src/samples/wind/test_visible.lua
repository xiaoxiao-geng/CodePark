module( ..., package.seeall )

function onCreate()
	local view = View { scene = scene }

	view2 = View { scene = scene }
	panel = Button { parent = view2, pos = { 100, 100 }, size = { 200, 100 } }
	button = Button { parent = panel, pos = { 10, 10 }, text = "hello" }

	Button { parent = view, pos = { 100, 200 }, text = "hide", onClick = function()
		view2:setVisible( false )
		debug( "hide" )
		end }

	Button { parent = view, pos = { 100, 300 }, text = "show", onClick = function()
		view2:setVisible( true )
		debug( "show" )
		end }

	debug( 1 )
end

function debug( tag )
	print("button", tag, button:getVisible())
end