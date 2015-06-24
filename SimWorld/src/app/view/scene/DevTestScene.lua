local DevTestScene = class("DevTestScene", mvc.ViewBase)

local menuConf = {
    { name = "给我钱", viewName = "_test_show_me_the_money" },
    { name = "Scene", viewName = "_test_scene" },
    { name = "Sprite", viewName = "_test_sprite" },
    { name = "Ease1", viewName = "_test_ease1" },
    { name = "Ease2", viewName = "_test_ease2" },
    { name = "Ease3", viewName = "_test_ease3" },
    { name = "AnimFrame", viewName = "_test_anim_frame" },
    { name = "UI", viewName = "_test_ui" },
    { name = "cfg", viewName = "_test_cfg" },
    -- { name = "ContentSize", viewName = "_test_content_size" },
    -- { name = "NodeEvent", viewName = "_test_node_event" },
    -- { name = "Class", viewName = "_test_class" },
    -- { name = "CustomEvent", viewName = "_test_custom_event" },
    -- { name = "ViewBaseEx", viewName = "_test_view_base_ex", context = {type = 1} },
    -- { name = "Record", viewName = "_test_record" },
    -- { name = "ClippingNode", viewName = "_test_clipping_node" },
    -- { name = "DrawNode", viewName = "_test_draw_node" },
    -- { name = "SpriteDrawNode", viewName = "_test_sprite_draw_node" },
    -- { name = "PlayerData", viewName = "_test_player_data" },
    -- { name = "DeskAlg", viewName = "_test_desk_alg" },
    { name = "IceCreamData", viewName = "_test_ice_cream_data" },
    { name = "IceCreamCupList", viewName = "_test_ice_cream_cup_list" },
    -- { name = "ImageGrid", viewName = "_test_image_grid" },
    { name = "CakeData", viewName = "_test_cake_data" },
    { name = "CakeMerge", viewName = "_test_cake_merge" },
    { name = "CakeCreamAnim", viewName = "_test_cake_cream_anim" },
    { name = "CakeFruitAnim", viewName = "_test_cake_fruit_anim" },
    { name = "CakeCandyTouch", viewName = "_test_cake_candy_touch" },
    { name = "IceCreamSprite", viewName = "_test_ice_cream_sprite" },
    { name = "Translate", viewName = "_test_translate" },
    { name = "ScrollDrag", viewName = "_test_scroll_drag" },
    { name = "Mask", viewName = "_test_mask" },
    { name = "Socket", viewName = "_test_socket" },
    { name = "UlSocket", viewName = "_test_ul_socket" },
    { name = "Network", viewName = "_test_network" },
    { name = "CompetitionNetwork", viewName = "_test_competition_network" },
    { name = "Particle", viewName = "_test_particle" },
    { name = "ProtoBuffer", viewName = "_test_proto_buffer" },
    { name = "Webp", viewName = "_test_webp" },
    { name = "RandomName", viewName = "_test_random_name" },
    { name = "Nail", viewName = "_test_nail" },
    { name = "Face", viewName = "_test_face" },
    { name = "Native", viewName = "_test_native" },
    { name = "SDKTest", viewName = "_test_sdk" },
    { name = "NetworkDownload", viewName = "_test_network_download" },
}

function DevTestScene:onCreate()
    print("DevTestScene.onCreate")
    
    local layerMenu = cc.Layer:create()

    local menu = cc.Menu:create()
    local menuItem = cc.MenuItemLabel:create(cc.Label:createWithTTF("Exit", "fonts/arial.ttf", 48))
    menuItem:registerScriptTapHandler(function() 
        --self:getApp():enterScene("scene.MainScene")
        ul.mgrModule:showModuleWithID(99)
    end)
    menu:addChild(menuItem)
    menu:setPosition(display.width - 50, display.height - 50)
    layerMenu:addChild(menu)

    local sw = display.width
    local sh = display.height
    local menu = cc.Menu:create()

    for i, v in pairs( menuConf ) do
        local ix = (i - 1) % 2
        local iy = math.floor((i - 1) / 2)

        local label = cc.Label:createWithTTF(v.name, ul.FONT, 24)
            :setSystemFontSize(24)
            -- :setFont(ul.FONT, 24)

        -- label:setSystemFontSize(24)
        -- label:setSystemFontName(ul.FONT)
        local menuItem = cc.MenuItemLabel:create(label)
        menuItem:registerScriptTapHandler(handler(self, self.onClickMenuItem))
        menuItem:setPosition(ix * 200, iy * -40)
        menu:addChild(menuItem, 10000 + i, 10000 + i)
    end

    menu:setContentSize(200, 200)
    menu:setPosition(100, sh - 100)

    layerMenu:addChild(menu)
    self:addChild(layerMenu)
end

function DevTestScene:onEnter()
    print("DevTestScene.onEnter")
end

function DevTestScene:onExit()
    print("DevTestScene.onExit")
end

function DevTestScene:onClickMenuItem(tag)
    local idx = tag - 10000

    local v = menuConf[idx]
    if not v then
        print("menuConf not found!")
        return
    end
    
--    self:getApp():enterScene("app.devTest._test_cfg")

    print("click", v.name)
--    self:getApp():enterScene("devTest." .. v.viewName)
    
    -- devTest._test_sprite
    local view = self:getApp():createView("devTest." .. v.viewName, v.context)
    view:showWithScene()
end

return DevTestScene