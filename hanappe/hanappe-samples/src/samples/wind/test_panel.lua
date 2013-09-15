module( ..., package.seeall )

function onCreate( params )
	view = View { scene = scene }
	view:setPriorityUpdateEnabled( true )

	panel1 = Panel { parent = view, pos = { 100, 100 }, size = { 400, 400 } }
	panel1:getPriority( 5 )

	panel2 = Panel { parent = view, pos = { 200, 200 }, size = { 400, 400 } }
	panel2:getPriority( 100 )

	-- view:updateLayout()

	print( "panel1:getPriority()", panel1:getPriority() )
	print( "panel2:getPriority()", panel2:getPriority() ) 
end