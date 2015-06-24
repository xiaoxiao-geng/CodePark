--[[
	启动器
]]

local function boot()
	release_print("")
	release_print("-------------------------------------------")
	release_print("----                                   ----")
	release_print("----             B.O.O.T.              ----")
	release_print("----                                   ----")
	release_print("----            bootting the world...  ----")
	release_print("-------------------------------------------")
	release_print("")


	-- 重新加载updater模块
	local unloadModules = {
		"config",
		"updater.Updater",
		"updater.UpdaterUi",
		}

	for _, name in pairs(unloadModules) do
		package.preload[name] = nil
		package.loaded[name] = nil
	end

	local Updater = require("updater.Updater")
	Updater.start(_G.UPDATER_BOOTED ~= true)

	-- 由于cocos会拦截全区变量的写入，这里处理一下
	if cc and cc.exports then
		cc.exports.UPDATER_BOOTED = true
	else
		_G.UPDATER_BOOTED = true
	end
end

boot()