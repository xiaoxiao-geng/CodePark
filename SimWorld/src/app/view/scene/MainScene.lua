local MainScene = class("MainScene", mvc.ViewBase)

function MainScene:onCreate()
    cc.Label:createWithSystemFont("hello world", nil, 24)
        :addTo(self)
        :move(display.width / 2, display.height / 2)
        :enableShadow()
end

function MainScene:onEnter()
    print("MainScene.onEnter")
end

function MainScene:onExit()
    print("MainScene.onExit")
end

return MainScene
