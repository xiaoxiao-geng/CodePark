--[[
	loading流程
	
	核心方法
	doLoad:执行一次load操作

	loadHandlers 所有加载操作的handler
	在onEnterFrame中一次加载

]]
local LoadingScene = class("LoadingScene", mvc.ViewBase)

function LoadingScene:onCreate()
	self:buildUi()

	self.loadHandlers = {}

	table.insert(self.loadHandlers, handler(mvc.ManagerBase, mvc.ManagerBase.resetAllManager))

	self.currStep = 1

	self:refreshProgress()
	self:onUpdate(handler(self, self.onEnterFrame))
end

function LoadingScene:buildUi()
end

function LoadingScene:onEnterFrame()
	local beginClock = os.clock()

	while true do
		if self.currStep > #self.loadHandlers then
			self:onLoadingComplete()
			return
		end

		-- 执行load操作
		local handler = self.loadHandlers[self.currStep]
		if type(handler) == "function" then
			xpcall(
				function()
					handler()
				end, 
				function(msg)
					release_print("doLoad has some error:", msg) 
					release_print("  step =", self.currStep)
				end
				)
		end
		self.currStep = self.currStep + 1

		-- 如果本次执行时间不足16毫秒，则继续执行
		if os.clock() - beginClock > 0.016 then
			break
		end
	end

	self:refreshProgress()
end

--[[
	显示进度
]]
function LoadingScene:refreshProgress()
	local percentr = ((self.currStep - 1) / #self.loadHandlers) * 100
	-- self.loadingBar:setPercent(percentr)
	-- self.labelProgress:setString(string.format("Loading: %d%%", math.floor(((self.currStep - 1) / #self.loadHandlers) * 100)))
end

--[[
	加载结束
]]
function LoadingScene:onLoadingComplete()
    self:getApp():enterScene("scene.MainScene")
end

return LoadingScene