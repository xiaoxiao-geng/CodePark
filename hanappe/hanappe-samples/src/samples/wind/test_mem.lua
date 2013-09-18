module( ..., package.seeall )

function onCreate( params )
	view = View { scene = scene }

	local memId = 1
	local btn1 = Button { parent = view, pos = { 600, 100 }, text = "show", onClick = createSimpleView }
	local btn2 = Button { parent = view, pos = { 600, 150 }, text = "x 10", onClick = function() for i = 1, 10 do createSimpleView() end end }
	local btn3 = Button { parent = view, pos = { 600, 200 }, text = "close", onClick = disposeSimpleView }
	local btn3 = Button { parent = view, pos = { 600, 250 }, text = "out", onClick = function() 
		MOAISim.forceGarbageCollection()
		MOAILogMgr.openFile("e:/mem/mem" .. memId .. ".txt")
		memId = memId + 1
		MOAISim.reportHistogram()
		MOAILogMgr.closeFile()
	end }
end

function createSimpleView()
	disposeSimpleView()

	local Component = require "hp/gui/Component"

	c1 = Panel { parent = view, name = "c1" }
	c2 = Panel { parent = c1, name = "c2" }
end

function disposeSimpleView()
	if c1 then
		c1:dispose()
	end

	if c2 then 
		c2:dispose()
	end

	c1 = nil
	c2 = nil
end