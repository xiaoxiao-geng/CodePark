-- MOAISim setting
MOAISim.setStep ( 1 / 60 )
MOAISim.clearLoopFlags ()
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_LONG_DELAY )
MOAISim.setBoostThreshold ( 0 )

-- Text Label
TextLabel.DEFAULT_COLOR = {0, 0, 0, 1}

-- Screen size setting
local screenWidth = MOAIEnvironment.horizontalResolution or 960
local screenHeight = MOAIEnvironment.verticalResolution or 640
local viewScale = 1 --screenWidth >= 640 and 2 or 1

-- Application config
local config = {
    title = "Hanappe samples",
    screenWidth = screenWidth,
    screenHeight = screenHeight,
    viewScale = viewScale,
    mainScene = "samples/sample_scene",
}

return config