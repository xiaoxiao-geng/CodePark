local MsgHandler = import(".MsgHandler")
local ViewBase = import("..mvc.ViewBase")

local ViewBaseEx = class("ViewBaseEx", ViewBase, MsgHandler)

function ViewBaseEx:onEnter_()
	getmetatable(self).onEnter_(self)
end

function ViewBaseEx:onExit_()
	getmetatable(self).onExit_(self)
end

function ViewBaseEx:onEnterTransitionFinish_()
	self:startProcMsg()

	getmetatable(self).onEnterTransitionFinish_(self)
end

function ViewBaseEx:onExitTransitionStart_()
	self:stopProcMsg()

	getmetatable(self).onExitTransitionStart_(self)
end

function ViewBaseEx:onCleanup_()
	self:setMsgListeners(nil)

	getmetatable(self).onCleanup_(self)
end

return ViewBaseEx
