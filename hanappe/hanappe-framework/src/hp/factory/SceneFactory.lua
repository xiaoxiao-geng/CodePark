----------------------------------------------------------------
-- Sceneを生成するファクトリークラスです.
-- SceneManagerにより使用されます.
----------------------------------------------------------------

-- import
local Scene = require("hp/display/Scene")

-- class
local M = {}

---------------------------------------
-- シーンを生成します.
-- この関数の動作を変更する事で、
-- 任意のロジックでシーンを生成する事が可能です.
-- @param name シーン名です.
--     シーン名をもとに、モジュールを参照して、
--     sceneHandlerを生成します.
--     ただし、params.handlerが指定された場合、
--     そのhandlerを使用します.
-- @param params パラメータです.
--     sceneClassがある場合、同クラスを生成します.
--     handlerがある場合、sceneHandlerに設定されます.
---------------------------------------
function M.createScene(name, params)
    assert(name, "name is nil!")
    
    local sceneClass = params.sceneClass or Scene
    local scene = sceneClass:new()
    scene.sceneHandler = params.handler or require(name)
    scene.name = name
    scene.sceneHandler.scene = scene
    params.scene = scene

    -- ul add begin
    -- 由于Game中require的Scene有可能会被改变，这里每次createScene后，将handler保存到全局变量中
    -- 将sceneHander保存在全局中
    if _G.SCENE_HANDLER_NAMES then
	    for k, v in pairs( _G.SCENE_HANDLER_NAMES ) do
	    	if v == name then
	    		_G[ k ] = scene.sceneHandler
	    	end
	    end
	end
    -- ul add end

    return scene
end

return M