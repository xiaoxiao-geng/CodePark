--[[
	程序主入口

	【警告】
	main.lua是唯一的一个不能更新的文件
	请将游戏代码放置在MyApp.lua中！
]]

cc.FileUtils:getInstance():setPopupNotify(false)

-- 判断是否有patch_info.json文件
-- 这里的策略是，需要打补丁的包，在src下总会找到一个src/patch_info.json
-- 如果用模拟器运行，没有这个文件，则说明不需要打补丁
if cc.FileUtils:getInstance():isFileExist("src/patch_info.json") then
	local writablePath = cc.FileUtils:getInstance():getWritablePath()
	addSearchPath(writablePath .. "src/", true)
	addSearchPath(writablePath .. "res/", true)

	release_print("con't find src/patch_info.json, custom searchPath to writablePath:", writablePath)
else
	release_print("con't find src/patch_info.json, use default searchPath.")
end

cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

--- 重启更新器
function rebootUpdater()
	local bootName = "updater.boot"
	package.preload[bootName] = nil
	package.loaded[bootName] = nil

	require(bootName)
end

rebootUpdater()