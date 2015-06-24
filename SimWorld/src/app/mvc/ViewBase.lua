local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name, context)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name
    self.context = context or {}

    -- check CSB resource file
    local res = self.class.RESOURCE_FILENAME  -- rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = self.class.RESOURCE_BINDING --rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end

    if self.onCreate then self:onCreate() end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

local function _findNodeByName(root, name)
    if root:getName() == name then
        return root
    end

    local children = root:getChildren()

    local node
    for _, child in pairs(children) do
        node = _findNodeByName(child, name)

        if node then return node end
    end

    return nil
end

function ViewBase:createResoueceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")

    local root = self.resourceNode_

    for nodeName, nodeBinding in pairs(binding) do
        local node = _findNodeByName(root, nodeName)
        if node then
            if nodeBinding.varname then
                self[nodeBinding.varname] = node
            end
            for _, event in ipairs(nodeBinding.events or {}) do
                if event.event == "touch" then
                    node:onTouch(handler(self, self[event.method]))
                end

                local bindMethod = event.bindMethod
                if bindMethod ~= nil then
                    local func = node[bindMethod]
                    -- print("func", tostring(func), bindMethod)
                    if type(func) == "function" then
                        func(node, handler(self, self[event.method]))
                    end
                end
            end
        else
            print("------------------------------------------ERROR--------------------------------------------")
            print("has no widget with node name ", nodeName)
        end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

function ViewBase:showFrontOnScene()
    local scene = display.getRunningScene()
    scene:addChild(self, 99)
    return self
end

function ViewBase:setContext(context)
    self.context = context or {}
end

return ViewBase
