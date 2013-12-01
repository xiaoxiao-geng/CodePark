module( ..., package.seeall )

local MAX = 1000

function onCreate()
	local view = View { scene = scene }

	Button { parent = view, pos = { 400, 100 }, size = { 100, 50 }, text = "reset", onClick = function() 
		print( "reset" )
		reset()
		end }

	Button { parent = view, pos = { 400, 160 }, size = { 100, 50 }, text = "-10", onClick = function() 
		print( "-10" )
		change( -10 )
		end }

	Button { parent = view, pos = { 400, 220 }, size = { 100, 50 }, text = "-100", onClick = function() 
		print( "-100" )
		change( - 100)
		end }

	bar = HpBar { parent = view, size = { 200, 30 }, pos = { 100, 100 } }

	reset()
end

function reset()
	bar:setValue( MAX, MAX )
end

function change( delta )
	bar:setHp( bar.hp + delta )
end