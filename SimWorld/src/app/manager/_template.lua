--[[
	管理器模板

	复制模板后，请将 "MANAGER_NAME" 替换为对应的mgr名字，如“mgrXxx”

	mgr相关用法，请参考 mvc.ManagerBase 头部的注释
]]
local MANAGER_NAME = class("MANAGER_NAME", mvc.ManagerBase)

----- 变量区 -----









----- 生命周期 -----
function MANAGER_NAME:onReset()
	-- 这里初始化、重置变量
end









----- 模块1 -----









----- 模块2 -----









return MANAGER_NAME