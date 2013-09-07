module(..., package.seeall)

function onCreate(params)
    view = View {
        scene = scene,
    }

    panel = Panel {
        name = "panel",
        size = {view:getWidth() - 20, view:getHeight() - 20},
        pos = {10, 10},
        parent = view,
    }

    local button = Button { name = "btn", text = "hello", parent = panel }
    button:setSize( 100, 60 )

end
