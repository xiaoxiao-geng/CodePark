
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 960,
    height = 640,
    autoscale = "FIXED_WIDTH",
    -- callback = function(framesize)
    --     local ratio = framesize.width / framesize.height
    --     local designRatio = CC_DESIGN_RESOLUTION.width / CC_DESIGN_RESOLUTION.height
    --     if ratio >= designRatio then
    --         --超过涉及比率的部分，改为固定高度（扩展宽度）
    --         return {autoscale = "FIXED_HEIGHT"}
    --     end
    -- end
}
