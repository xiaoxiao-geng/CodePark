--[[
	更新器

    更新流程：

    1. 准备更新
        检测patch_info是否存在，如果不存在则不需要更新
        检测包的版本和本地存档的版本是否相同，如果不相同则重置补丁（在不删除存档的情况下换包）
        提取本地pid

]]

local Updater = {}

-- 这里只能引用：
--     C模块
--     updater模块内的代码
local cjson = require("cjson")
local UpdaterUi = require("updater.UpdaterUi")








----- 变量定义区 ------
local DEBUG = true
Updater.patchInfo = nil
Updater.localPid = nil
Updater.patchs = nil
Updater.patchIdx = nil

Updater.TIMEOUT = 5








----- 生命周期 -----
function Updater.start(bFirstBoot)
	print("Updater.start, Updater's address:", tostring(Updater))
    print("  bFirstBoot", bFirstBoot)

    -- 计算是否需要播放logo
    -- 1. 第一次运行
    -- 2. 找到patch_info文件
    local bNeedPlayLogo = bFirstBoot and Updater.needPlayLogo()

    -- 如果需要播放logo，可以利用bFirstBoot这个字段判断是否为第一次进入游戏
    if bNeedPlayLogo then
        UpdaterUi.playLogo(Updater.prepareUpdate)
    else
        -- 准备更新
        Updater.prepareUpdate()
    end
end

-- 开始app
function Updater.startApp()
    -- 1. 卸载ui
    UpdaterUi.exit()

    -- 2. 卸载资源管理器
    Updater.releaseAssetsManager()

    -- 3. 停止xhr
    Updater.releaseRequestPatchInfoXhr()

    -- 4. 启动app
    release_print("Updater.startApp")
    release_print(debug.traceback())
    release_print("")
    release_print("-------------------------------------------")
    release_print("----                                   ----")
    release_print("----          Updater.startApp         ----")
    release_print("----                                   ----")
    release_print("-------------------------------------------")
    release_print("")

	require "config"
	require "cocos.init"

	local function main()
	    require("app.MyApp"):create():run()
	end

	release_print("")
	release_print("Updater: start app")
	release_print(debug.traceback())
	release_print("")

	local status, msg = xpcall(main, __G__TRACKBACK__)
	if not status then
	    release_print(msg)
	end
end

-- 重启更新器
function Updater.reboot()
    -- 1. 卸载ui
    UpdaterUi.exit()

    -- 2. 卸载资源管理器
    Updater.releaseAssetsManager()

    -- 3. REBOOT!
    _G.rebootUpdater()
end








----- 工具函数 ------
local function string_split( self, delim, toNumber )
    
    local start = 1
    local t = {}  -- results table
    local newElement
    -- find each instance of a string followed by the delimiter
    while true do
        local pos = string.find (self, delim, start, true) -- plain find
        if not pos then
            break
        end
        -- force to number
        newElement = string.sub (self, start, pos - 1)
        if toNumber then
            newElement = string.toNumber(newElement) --newElement:toNumber()
        end
        table.insert (t, newElement)
        start = pos + string.len (delim)
    end -- while

    -- insert final one (after last delimiter)
    local value =  string.sub (self, start)
    if toNumber then
        value = string.toNumber(value) --value:toNumber()
    end
    table.insert (t,value )
    return t
end

local function string_trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function dump(value, desciption, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local traceback = string_split(debug.traceback("", 2), "\n")
    release_print("dump from: " .. string_trim(traceback[3] or ""))

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        release_print(line)
    end
end









----- 更新器逻辑 -----

function Updater.needPlayLogo()
    return cc.FileUtils:getInstance():isFileExist( "patch_info.json" )
end

--- 准备更新
function Updater.prepareUpdate()
	-- 1. 检查本地patch_info.json
    local jsonText = cc.FileUtils:getInstance():getStringFromFile( "patch_info.json" ) or ""
    local patchInfo = nil
    if jsonText ~= "" then
        patchInfo = cjson.decode(jsonText)
    end
    Updater.patchInfo = patchInfo

    if not patchInfo then
    	_G.GAME_VERSION = "unknown"
    	release_print("[warn] patch_info.json 没有找到，不能更新")
    	Updater.startApp()
    	return
    end
    _G.GAME_VERSION = patchInfo.VERSION
    _G.GAME_CHANNEL = patchInfo.CHANNEL





    -- 2. 检测包版本和存档版本，判断是否需要重置补丁

    -- 安装包的bid
    local packageBid = patchInfo.B_ID
    -- 安装包的pid
    local packagePid = patchInfo.P_ID
    -- 安装包的cfg
    local packageChannel = patchInfo.CHANNEL

    -- 检查本地存档的版本
    local recordBid        = tonumber(cc.UserDefault:getInstance():getStringForKey("PATCHER_BID"))
    local recordPid        = tonumber(cc.UserDefault:getInstance():getStringForKey("PATCHER_PID"))
    local recordPackagePid = tonumber(cc.UserDefault:getInstance():getStringForKey("PATCHER_PACKAGE_PID"))
    local recordChannel    = cc.UserDefault:getInstance():getStringForKey("PATCHER_CHANNEL")

    -- 如果bid和channel不匹配，则重置补丁
    -- 如果package中的pid比存档的pid高，则重置补丁
    local resetTip = nil
    if packageBid ~= recordBid then
        resetTip = string.format("bid not match! package = %s, record = %s", tostring(packageBid), tostring(recordBid))

    elseif packageChannel ~= recordChannel then
        resetTip = string.format("bid not match! package = %s, record = %s", tostring(packageChannel), tostring(recordChannel))

    elseif packagePid ~= recordPackagePid then
        resetTip = string.format("package pid not match! package = %s, record = %s", tostring(packagePid), tostring(recordPackagePid))

    elseif packagePid > (recordPid or 0) then
        resetTip = string.format("package pid is higher! package = %s, record = %s", tostring(packagePid), tostring(recordPid))
    end

    if resetTip then
		Updater.resetPatcher(resetTip, packageBid, packagePid, packageChannel)
    end





    -- 3. 提取当前本地的pid
    local localPid = nil
    local recordPid = tonumber(cc.UserDefault:getInstance():getStringForKey("PATCHER_PID"))
    if recordPid then
        -- 使用存档中的pid
        localPid = recordPid

        if DEBUG then print("use record pid", localPid) end
    else
        -- 使用随包写到的patch_info中的pid
        localPid = patchInfo.P_ID or 0

        if DEBUG then print("use patch_info pid", localPid) end
    end
    Updater.localPid = localPid





    -- 4. 准备下载路径
    local downloadPath = cc.FileUtils:getInstance():getWritablePath()
    if not cc.FileUtils:getInstance():createDirectory(downloadPath) then
        -- 下载路径创建失败
        Updater.startApp()
        return
    end
    Updater.downloadPath = downloadPath






    -- 5. 创建ui
    UpdaterUi.enter(Updater)






    Updater.checkNewVersion()
end

--- 发送ui消息
function Updater.sendUiMsg(msg, ...)
    -- print("sendUiMsg", msg, ...)
    UpdaterUi.onMsg(msg, ...)
end

--- 检测更新
function Updater.checkNewVersion()
    Updater.sendUiMsg("UPDATER_UI_MSG_GET_VERSION")

	local patchInfo = Updater.patchInfo

    local patchInfoUrl = string.format("http://%s/%s/%s/%s/%s",
    	tostring(patchInfo.HOST),
    	tostring(patchInfo.PATCH_PATH),
    	tostring(patchInfo.APP),
    	tostring(patchInfo.CHANNEL),
    	tostring(patchInfo.PATCH_INFO_FILENAME)
    	)
    release_print("patchInfoUrl", patchInfoUrl)

    local xhr = cc.XMLHttpRequest:new()
    xhr:retain()
    Updater.requestPatchInfoXhr = xhr

    local function onReadyStateChange()
        print("onReadyStateChange ", xhr.readyState)
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            Updater.stopTimeoutTimer()

            -- 提取remote config
            local remotePatchInfo = cjson.decode(xhr.response)
            if remotePatchInfo then 
                Updater.releaseRequestPatchInfoXhr()
                Updater.onPatchInfoDownloadSuccess(remotePatchInfo)
            else
                -- patch_info错误，直接进入游戏
                Updater.startApp()
            end
        else
            -- 网络错误，直接进入游戏不更新
            Updater.stopTimeoutTimer()
            Updater.startApp()
        end
    end

    Updater.startTimeoutTimer()

    -- 开启http请求，下载最新的patch_info.json
    local XMLHTTPREQUEST_RESPONSE_STRING = 0
    xhr.responseType = XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", patchInfoUrl)
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

function Updater.onPatchInfoDownloadSuccess(remotePatchInfo)
    -- 保存patchInfo
    Updater.patchInfo = remotePatchInfo
    _G.GAME_VERSION = remotePatchInfo.VERSION

    if DEBUG then
        release_print("remote patch_info:")
        dump(remotePatchInfo)
    end

    -- 提取pid
    local remotePid = tonumber(remotePatchInfo.P_ID)
    local localPid = Updater.localPid

    -- 提取需要下载的补丁
    local patchs = {}
    for i, v in ipairs(remotePatchInfo.PATCH_LIST) do
        if v.pid > localPid then
            -- 版本号比本地pid高，需要更新
            table.insert(patchs, v)
        end
    end

    if #patchs > 0 then
        Updater.patchs = patchs
        Updater.patchIdx = 1

        Updater.downloadPatchByIndexed()
    else
        -- 不需要下载补丁
        Updater.startApp()
    end
end

--- 下载idx对应的补丁
function Updater.downloadPatchByIndexed()
    Updater.releaseAssetsManager()

    local function onError(errorCode)
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
             Updater.sendUiMsg("UPDATER_UI_MSG_DOWNLOAD_ERROR_NO_NEW_VERSION")
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            Updater.sendUiMsg("UPDATER_UI_MSG_DOWNLOAD_ERROR_NETWORK")
        else
            print("unknown err, err code:".. errorCode)
            Updater.sendUiMsg("UPDATER_UI_MSG_DOWNLOAD_ERROR_NETWORK")
        end

        -- 失败后进入游戏
        Updater.startApp()
    end

    local function onProgress( percent )
        Updater.sendUiMsg("UPDATER_UI_MSG_DOWNLOAD_PROGRESS", percent)
    end

    local function onSuccess()
        Updater.sendUiMsg("UPDATER_UI_MSG_DOWNLOAD_SUCCESS")

        Updater.onPatchDownloadSuccess()
    end

    local patchInfo = Updater.patchInfo
    local patch = Updater.patchs[Updater.patchIdx]
    local patchUrl = string.format("http://%s/%s/%s/%s/%s/%s.zip",
        tostring(patchInfo.HOST_CDN or patchInfo.HOST), -- 尝试使用CDN地址下载zip包)
        tostring(patchInfo.PATCH_PATH),
        tostring(patchInfo.APP),
        tostring(patchInfo.CHANNEL),
        tostring(patchInfo.B_ID),
        tostring(patch.pid)
        )
    if DEBUG then
        release_print("patchUrl", patchUrl)
    end

    local assetsManager = cc.AssetsManager:new(
        patchUrl,
        patchInfo.HOST .. "/fake_version",
        Updater.downloadPath
        )
    Updater.assetsManager = assetsManager

    local ASSETSMANAGER_PROTOCOL_PROGRESS =  0
    local ASSETSMANAGER_PROTOCOL_SUCCESS  =  1
    local ASSETSMANAGER_PROTOCOL_ERROR    =  2

    assetsManager:deleteVersion()
    assetsManager:retain()
    assetsManager:setDelegate(onError, ASSETSMANAGER_PROTOCOL_ERROR )
    assetsManager:setDelegate(onProgress, ASSETSMANAGER_PROTOCOL_PROGRESS)
    assetsManager:setDelegate(onSuccess, ASSETSMANAGER_PROTOCOL_SUCCESS )
    assetsManager:setConnectionTimeout(3)

    assetsManager:update()
end

function Updater.onPatchDownloadSuccess()
    local patch = Updater.patchs[Updater.patchIdx]

    -- 保存pid
    Updater.localPid = patch.pid
    cc.UserDefault:getInstance():setStringForKey("PATCHER_PID", Updater.localPid)
    cc.UserDefault:getInstance():flush()
    if DEBUG then release_print("\n () ()\n( @ @ )\n(  -  )    save pid:", Updater.localPid) end

    if patch.reboot then
        -- 需要重启更新器
        Updater.reboot()
        return
    end

    -- 判断补丁是否下载完毕
    if Updater.patchIdx < #Updater.patchs then 
        Updater.patchIdx = Updater.patchIdx + 1
        Updater.downloadPatchByIndexed()
    else
        Updater.startApp()
    end
end

--- 释放AssetsManager
function Updater.releaseAssetsManager()
    if Updater.assetsManager then
        Updater.assetsManager:release()
        Updater.assetsManager = nil
    end
end

--- 释放xhr
function Updater.releaseRequestPatchInfoXhr()
    if Updater.requestPatchInfoXhr then
        Updater.requestPatchInfoXhr:release()
        Updater.requestPatchInfoXhr:abort()
        Updater.requestPatchInfoXhr = nil
    end
end

--- 重置补丁
-- 重置存档中的bid、pid、channel
-- 删除已下载的补丁文件
function Updater.resetPatcher(tip, bid, pid, channel)
    release_print("")
    release_print("")
    release_print("[warn] resetPatcher:", tip)
    release_print("")
    release_print("")

    -- 1. 清理已下载补丁的res和src目录
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local fileUtils = cc.FileUtils:getInstance()
    if fileUtils:isDirectoryExist(writablePath .. "/src/") then
        cc.FileUtils:getInstance():removeDirectory(writablePath .. "/src/")
    end
    if fileUtils:isDirectoryExist(writablePath .. "/res/") then
        cc.FileUtils:getInstance():removeDirectory(writablePath .. "/res/")
    end

    -- 2. 更新存档
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setStringForKey("PATCHER_BID", bid)
    userDefault:setStringForKey("PATCHER_PID", pid)
    userDefault:setStringForKey("PATCHER_PACKAGE_PID", pid)
    userDefault:setStringForKey("PATCHER_CHANNEL", channel)
    userDefault:flush()
end










----- 超时检测 -----
function Updater.startTimeoutTimer()
    Updater.stopTimeoutTimer()

    local scheduler = cc.Director:getInstance():getScheduler()
    Updater.schdulerId = scheduler:scheduleScriptFunc(function()
            -- print("time up!")
            Updater.stopTimeoutTimer()
            Updater.onTimeout()
        end,Updater.TIMEOUT, false )
end

function Updater.stopTimeoutTimer()
    if not Updater.schdulerId then return end

    local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:unscheduleScriptEntry(Updater.schdulerId)
end

function Updater.onTimeout()
    -- 超时后跳过更新
    Updater.startApp()
end










return Updater