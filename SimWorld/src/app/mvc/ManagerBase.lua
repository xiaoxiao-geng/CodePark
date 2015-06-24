--[[
	mgr基类
	mgr作为游戏中数据、逻辑的核心
	每个模块都有一个mgr，该模块的数据都存放在mgr中

	mgr为全局变量，在其他代码中可以通过 ul.mgrXxx 进行访问
	mgr中如果需要通知view，则需要通过msg的方式进行发送
		self:getApp():sendMsg("MSG_NAME", data)

	对于一个View的生命周期：
	1. 创建，在View.onEnter中，通过 ul.mgrXxx 访问自身对应的mgr，获取数据后填充ui
	2. 数据更新，mgr中有数据更新后，发送msg进行广播，View.onMsgXxx 收到消息后，自行访问对应的mgr获取新的数据进行填充
	3. 状态信息（如购买成功的回调），mgr发送msg进行广播，在msg中带上“非持久化”的数据，View收到msg后，从参数中获取数据，进行处理
]]
local MsgHandler = import("..cocosExt.MsgHandler")

local ManagerBase = class("ManagerBase", MsgHandler)

-- 将所有Mananger子类的实例保存起来
ManagerBase._instances = {}









----- 类方法 -----

-- 设置app对象
function ManagerBase.setApp(app)
	ManagerBase._app = app
end

-- 重置所有的manager
function ManagerBase.resetAllManager()
	for _, manager in ipairs(ManagerBase._instances) do
		xpcall(
			function() 
				manager["instance"]:onReset()
			end,
			function(err)
				release_print("[warn] ManagerBase.resetAllManager has error:", err)
				release_print(debug.traceback())
			end
			)
		
	end
end

-- 保存mgr实例
function ManagerBase.saveMgrInstance(aName, aInstance)
    ManagerBase._instances[#ManagerBase._instances + 1] = {name = aName, instance = aInstance}
end











--- 重置
-- 可以当做Manager的初始化函数
function ManagerBase:onReset()
end

--- 获取app对象
function ManagerBase:getApp()
	return ManagerBase._app
end

return ManagerBase