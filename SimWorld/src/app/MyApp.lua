import(".init")

local MyApp = class("MyApp", mvc.AppBase)

function MyApp:ctor()
    mvc.ManagerBase.setApp(self)

    MyApp.super.ctor(self, {
        viewsRoot  = "app.view",
       -- modelsRoot = "app.models",
        defaultSceneName = "scene.LoadingScene"
        })
end

-- function MyApp:run()
    -- ul.mgrModule:showModuleWithID(1)
-- end

function MyApp:onCreate()
    math.randomseed(os.time())
end








----- msg相关 -----
function MyApp:sendMsg(msg, data)
    local e = cc.EventCustom:new(msg)
    e.data = data

    cc.Director:getInstance():getEventDispatcher():dispatchEvent(e)
end

return MyApp
