--[[
    更新器UI
]]

local UpdaterUi = {}

require("config")









----- 变量区 -----
UpdaterUi.bEntered = false
UpdaterUi.updater = nil








----- display copy区域 -----
-- cocos游戏启动的时候在display中设置了很多信息，这里将需要的信息copy过来

local director = cc.Director:getInstance()
local view = director:getOpenGLView()

if not view then
    local width = 960
    local height = 640
    if CC_DESIGN_RESOLUTION then
        if CC_DESIGN_RESOLUTION.width then
            width = CC_DESIGN_RESOLUTION.width
        end
        if CC_DESIGN_RESOLUTION.height then
            height = CC_DESIGN_RESOLUTION.height
        end
    end
    view = cc.GLViewImpl:createWithRect("Cocos2d-Lua", cc.rect(0, 0, width, height))
    director:setOpenGLView(view)
end

local function checknumber(value, base)
    return tonumber(value, base) or 0
end

local function checkResolution(r)
    r.width = checknumber(r.width)
    r.height = checknumber(r.height)
    r.autoscale = string.upper(r.autoscale)
    assert(r.width > 0 and r.height > 0,
        string.format("display - invalid design resolution size %d, %d", r.width, r.height))
end

local ResolutionPolicy =
{
    EXACT_FIT = 0,
    NO_BORDER = 1,
    SHOW_ALL  = 2,
    FIXED_HEIGHT  = 3,
    FIXED_WIDTH  = 4,
    UNKNOWN  = 5,
}

local function setDesignResolution(r, framesize)
    if r.autoscale == "FILL_ALL" then
        view:setDesignResolutionSize(framesize.width, framesize.height, ResolutionPolicy.FILL_ALL)
    else
        local scaleX, scaleY = framesize.width / r.width, framesize.height / r.height
        local width, height = framesize.width, framesize.height
        if r.autoscale == "FIXED_WIDTH" then
            width = framesize.width / scaleX
            height = framesize.height / scaleX
            view:setDesignResolutionSize(width, height, ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "FIXED_HEIGHT" then
            width = framesize.width / scaleY
            height = framesize.height / scaleY
            view:setDesignResolutionSize(width, height, ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "EXACT_FIT" then
            view:setDesignResolutionSize(r.width, r.height, ResolutionPolicy.EXACT_FIT)
        elseif r.autoscale == "NO_BORDER" then
            view:setDesignResolutionSize(r.width, r.height, ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "SHOW_ALL" then
            view:setDesignResolutionSize(r.width, r.height, ResolutionPolicy.SHOW_ALL)
        else
            release_print(string.format("display - invalid r.autoscale \"%s\"", r.autoscale))
        end
    end
end

local function setAutoScale(configs)
    if type(configs) ~= "table" then return end

    local framesize = view:getFrameSize()

    checkResolution(configs)
    if type(configs.callback) == "function" then
        local c = configs.callback(framesize)
        for k, v in pairs(c or {}) do
            configs[k] = v
        end
        checkResolution(configs)
    end

    setDesignResolution(configs, framesize)
end

if type(CC_DESIGN_RESOLUTION) == "table" then
    setAutoScale(CC_DESIGN_RESOLUTION)
end

local function c4b( _r,_g,_b,_a )
    return { r = _r, g = _g, b = _b, a = _a }
end









------ 生命周期 ------
function UpdaterUi.enter(updater)
    if UpdaterUi.bEntered then
        UpdaterUi.exit()
    end

    UpdaterUi.updater = updater

    UpdaterUi.bEntered = true

    -- 调整分辨率

    local scene = cc.Scene:create()

    if director:getRunningScene() then
        director:replaceScene(scene)
    else
        director:runWithScene(scene)
    end

    local size = director:getWinSize()
    UpdaterUi.buildUi(scene, size.width, size.height)
end

function UpdaterUi.exit()
    UpdaterUi.bEntered = false

    if UpdaterUi.rootNode then
        UpdaterUi.rootNode:removeFromParent()
        UpdaterUi.rootNode = nil
    end

    UpdaterUi.loadingBar = nil
    UpdaterUi.labelTip = nil
end

function UpdaterUi.playLogo(onCompelte)
    print("")
    print("UpdaterUi.playLogo")
    print("")

    local size = director:getWinSize()

    -- logo
    local spriteLogo1 = cc.Sprite:create("ui/common/loading/logo_alpha.png")
    if not spriteLogo1 then
        onCompelte()
        return
    end

    local spriteLogo2 = cc.Sprite:create("ui/common/loading/logo_ultralisk.png")
    if not spriteLogo2 then
        onCompelte()
        return
    end

    -- logo缩放到屏幕尺寸的90%
    local logoSize1 = spriteLogo1:getContentSize()
    local tw, th = size.width * 0.6, size.height * 0.6
    local scale = math.min(tw / logoSize1.width, th / logoSize1.height)
    spriteLogo1:setScale(scale)
    spriteLogo1:setPosition(size.width / 2, size.height / 2)


    local logoSize2 = spriteLogo2:getContentSize()
    local tw, th = size.width * 0.8, size.height * 0.8
    local scale = math.min(tw / logoSize2.width, th / logoSize2.height)
    spriteLogo2:setScale(scale)
    spriteLogo2:setPosition(size.width / 2, size.height / 2)

    -- 背景白色
    local bg = cc.LayerColor:create(c4b(255, 255, 255, 255))
        :setContentSize(size)
        :setPosition(0, 0)

    local scene = cc.Scene:create()

    if director:getRunningScene() then
        director:replaceScene(scene)
    else
        director:runWithScene(scene)
    end

    scene:addChild(bg)
    scene:addChild(spriteLogo1)
    scene:addChild(spriteLogo2)

    spriteLogo1:setOpacity(0)
    spriteLogo1:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(0.6),
            cc.DelayTime:create(0.8),
            cc.FadeOut:create(0.6)
        )
    )

    spriteLogo2:setOpacity(0)
    spriteLogo2:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(2),
            cc.FadeIn:create(0.6),
            cc.DelayTime:create(0.8),
            cc.FadeOut:create(0.6),
            cc.CallFunc:create(onCompelte)
        )
    )
end

function UpdaterUi.buildUi(scene, sw, sh)
    --[[
        提示
        由于updater并没有引入cocos-lua的辅助函数
        cocos目录下的辅助方法均不能使用
        如果需要，请参照上面c4b的方式，将函数移植为 local function

        诸如此类：
            addTo
            move
            cc.p
    ]]

    -- 根节点
    local rootNode = cc.Node:create()
        :setPosition(0, 0)
    scene:addChild(rootNode)



    -- bg
    local spriteBg = cc.Sprite:create("ui/common/loading/bg.png")
        :setPosition(sw / 2, sh / 2)
    rootNode:addChild(spriteBg)

    local bgSize = spriteBg:getContentSize()
    local scale = math.max(sh / bgSize.height, sw / bgSize.width)
    spriteBg:setScale(scale)

    -- tip
    local labelTip = cc.Label:createWithTTF("更新器启动中...", "fonts/test.ttf", 24)
        :setPosition(sw / 2, sh * 0.5 - 250)
    rootNode:addChild(labelTip)
    labelTip:setTextColor(c4b(255, 242, 212, 255))
    labelTip:enableOutline(c4b(69, 55, 29, 255), 2)

    -- loadingBar
    local spriteLoadingBg = cc.Sprite:create("ui/common/loading/prog_bg.png")
        :setPosition(sw / 2, sh * 0.5 - 300)
    rootNode:addChild(spriteLoadingBg)

    local loadingBar = ccui.LoadingBar:create()
        :setPosition(sw / 2, sh * 0.5 - 300)
        :loadTexture("ui/common/loading/prog_bar.png")
        :setContentSize(488, 47)
        :setPercent(0)
    rootNode:addChild(loadingBar)

    UpdaterUi.rootNode = rootNode
    UpdaterUi.loadingBar = loadingBar
    UpdaterUi.labelTip = labelTip
end








----- 消息 -----
function UpdaterUi.onMsg(msg, ...)
    if msg == "UPDATER_UI_MSG_DOWNLOAD_PROGRESS" then
        local percent = unpack({...})
        UpdaterUi.labelTip:setString(string.format("游戏更新中..."))
        UpdaterUi.updateProgress(percent)

    elseif msg == "UPDATER_UI_MSG_DOWNLOAD_ERROR_NO_NEW_VERSION" then
        UpdaterUi.labelTip:setString("补丁下载失败：没有更新")
        UpdaterUi.updateProgress(0)

    elseif msg == "UPDATER_UI_MSG_DOWNLOAD_ERROR_NETWORK" then
        UpdaterUi.labelTip:setString("补丁下载失败：网络错误")
        UpdaterUi.updateProgress(0)

    elseif msg == "UPDATER_UI_MSG_DOWNLOAD_SUCCESS" then

    elseif msg == "UPDATER_UI_MSG_GET_VERSION" then
        UpdaterUi.labelTip:setString("正在检查更新")
        UpdaterUi.loadingBar:setPercent(0)
    end
end

function UpdaterUi.updateProgress(currPercent)
    if not UpdaterUi.updater then return end

    local patchCount = #(UpdaterUi.updater.patchs or {})
    local patchIdx = UpdaterUi.updater.patchIdx or 0

    -- 进度条的算法
    --[[
        首先按照补丁的数量进行拆分
        每个补丁的进度按照currPercent进行填充
    ]]
    local percent = (currPercent + (patchIdx - 1) * 100) / patchCount
    UpdaterUi.loadingBar:setPercent(percent)
end


return UpdaterUi