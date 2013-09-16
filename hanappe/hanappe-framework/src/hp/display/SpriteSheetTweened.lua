--------------------------------------------------------------------------------
-- Flash tweened anim cdsc add
--------------------------------------------------------------------------------

-- import
local class                     = require "hp/lang/class"
local SpriteSheet               = require "hp/display/SpriteSheet"
local Logger                    = require "hp/util/Logger"
local Event                     = require "hp/event/Event"
-- class
local M                         = class(SpriteSheet)
local super                     = SpriteSheet
--------------------------------------------------------------------------------
-- The constructor.<br>
-- see SpriteSheet.init
--------------------------------------------------------------------------------
function M:init(params)
    super.init(self, params)

    self.sprites    = {}
    self.step       = 0
    self.onComplete = nil
    self.onStop     = nil
    self.curProps   = {}
    self.deck       = nil

    self.eventCallback = {}

end

function M:dispose()
    self:stopAnim()
    super.dispose(self)
end

function M:loadFromFlash(fileName)

    local animData  = dofile(fileName)
    local deck      = self:createDeck(fileName, animData)
   
    self:loadFromData(animData, deck)
    
end

function M:createDeck(fileName, animData)

    animData = animData or dofile(fileName)
    
    local texturePath   = self:getFileDir(fileName) .. animData.texture
    local texture       = TextureManager:request(texturePath)
    local deck          = self:getDeckFromFlashData(animData)
    deck:setTexture(texture)

    return deck
end

function M:loadFromData(data, deck)

    self.step           = 1 / data.fps

    for i, v in ipairs(data.anim) do
        local animName  = v.name
        local anim      = self:getAnimFromData(v, deck)
        anim.name       = animName
        self.animTable[ animName ] = anim
    end

    self:addEventListeners()

end

--动画每次播放完成
function M:setCompleteListener(func)
    self.onComplete = func
end
--动画跑完停止
function M:setStopListener(func)
    self.onStop = func
end

function M:getFileDir( path )

    local endLoc = nil
    local startLoc = 0
    while true do
        local loc = string.find(path, '/', startLoc)
        if not loc then 
            break 
        end
        endLoc = loc
        startLoc = loc+1
    end

    local dir = nil
    if endLoc then
        dir = string.sub(path,0, endLoc)
    end
    return dir
end

function M:getDeckFromFlashData(data)

    local quadDeck  = MOAIGfxQuadDeck2D.new ()
    local brushDeck = data.brushDeck
    local len       = #brushDeck
    local SEC_LEN   = 7
    quadDeck:reserve ( len / SEC_LEN )

    local i = 1
    for base = 1, len - 1, SEC_LEN do
        quadDeck:setUVRect( i, brushDeck[ base ], brushDeck[ base + 1 ], brushDeck[ base + 2 ], brushDeck[ base + 3 ] )
        
        local w = brushDeck[ base + 4 ] * 0.5
        local h = brushDeck[ base + 5 ] * 0.5

        if ( brushDeck[ base + 6 ] == 1 ) then
            quadDeck:setQuad( i, h, w, h, -w, -h, -w, -h, w )
        else
            quadDeck:setRect( i, -w, -h, w, h )
        end 
        i = i + 1
    end

    return quadDeck

end

function M:getAnimTimeLineFromData(data)
    local curves = self:getCurvesFromData(data)


    local timeLine = MOAIAnimCurve.new()


    local allKeys = curves

    local rangeKeys = {}
    for k, v in pairs(allKeys) do
        table.insert(rangeKeys, {pos = k, keys = v})
    end
    table.sort(rangeKeys, function(a,b) return a.pos < b.pos end)


    local nkeys = #rangeKeys
    timeLine:reserveKeys(nkeys)
    for i, v in ipairs(rangeKeys) do
        local pos = v.pos
        timeLine:setKey(i, pos * self.step, pos, MOAIEaseType.FLAT)
    end
    return timeLine, allKeys
end

local function mfStopPropActions(prop)
    if prop.locAct then
        prop.locAct:stop()
    end

    if prop.rotAct then
        prop.rotAct:stop()
    end

    if prop.sclAct then
        prop.sclAct:stop()
    end

    if prop.colorAct then
        prop.colorAct:stop()
    end
end

local function mfOnAnimKeyFrame(self, idx, time, v, value)

    local allkeys    = self.keys
    local keyInLayer = allkeys[value]
    if not keyInLayer then
        return
    end
    if not self.sprites or #self.sprites == 0 then
        return
    end
    for kk, vv in ipairs(keyInLayer) do

        local layerId   = vv.layerId
        local id        = vv.id
        local mode      = vv.mode
        self.curProps   = {}
        local prop      = self.sprites[layerId]
        if prop then
            table.insert(self.curProps, prop)
            prop:setIndex(id)

            mfStopPropActions(prop)
        
            local trans     = vv.transform
            if trans then
                prop:setLoc(trans[1], trans[2], 0)
                prop:setRot(0,0,trans[3])
                prop:setScl(trans[4], trans[5], 1)
                prop:setColor(trans[7], trans[8], trans[9], trans[6])
            end 

            local trans_next= vv.transform_next
            if trans_next and mode ~= MOAIEaseType.FLAT then
                local length = vv.length
                prop.locAct = prop:seekLoc(trans_next[1], trans_next[2], 0, length ,mode)
                prop.rotAct = prop:seekRot(0, 0, trans_next[3], length,mode)
                prop.sclAct = prop:seekScl(trans_next[4], trans_next[5], 1, length,mode)
                prop.colorAct = prop:seekColor(trans_next[7], trans_next[8], trans_next[9], trans_next[6],length ,mode)
            end
        else
            Logger.error("cannot find prop when draw find tweendAnim!!", layerId)
        end
    end
end

function M:getAnimFromData(data, deck)
    local anim = MOAIAnim.new()

    local timeLine, allkeys = self:getAnimTimeLineFromData(data)
    anim:setCurve(timeLine)

    local layers = data.layers
    for i = 1, #layers do
        local sprite = SpriteSheet()
        sprite:setAttrLink(MOAIProp.INHERIT_TRANSFORM, self, MOAIProp.TRANSFORM_TRAIT) 
        sprite:setDeck ( deck )
        sprite:setIndex(-1)
        table.insert ( self.sprites, sprite )
    end

    anim.keys  = allkeys
    anim.sprites = self.sprites
    anim:setListener ( MOAITimer.EVENT_TIMER_KEYFRAME, mfOnAnimKeyFrame )

    local _onEndSpan    = function (this)
                            if self.onComplete then
                                self.onComplete(self, this.name)
                            end
                        end
    anim:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, _onEndSpan)

    local _onStop = function(this)
                        if self.onStop then
                            self.onStop(self, this.name)
                        end
                    end
    anim:setListener ( MOAITimer.EVENT_STOP, _onStop )
    anim:setSpan(timeLine:getLength())
    anim:apply ( 0 )

    return anim
end

function M:mfGetCurveSet(layerData)

    local keys = {}
    local frames = layerData.frames
    for i, frame in ipairs(frames) do
        local id = frame.id
        local frame_next = frames[ i + 1 ]
        local id_next = frame_next and frame_next.id
        local mode = MOAIEaseType.FLAT
        if id_next and id == id_next and frame.length > 1 then
            mode = MOAIEaseType.LINEAR
        end
        local transform         = frame.transform
        local transform_next    = frame_next and frame_next.transform
        local time_length       = frame.length * self.step
        local key = 
        {
            ['id']              = frame.id,
            ['mode']            = mode,
            ['length']          = time_length,
            ['transform']       = transform,
            ['transform_next']  = transform_next,
        }
        local time = frame.start
        keys[time] = key
    end

    return keys
end

function M:getCurvesFromData(data)
    local keyAll = {}
    for i, layer in ipairs ( data.layers ) do
        local keys = self:mfGetCurveSet(layer)
        for k, v in pairs(keys) do
            keyAll[k] = keyAll[k] or {}
            v.layerId = i
            table.insert(keyAll[k], v)
        end
    end
    return keyAll
end

function M:setLayer(layer)

    for i, v in ipairs(self.sprites) do
        v:setLayer(layer)
    end

end

--------------------------------------------------------------------------------
-- Start the animation.
--------------------------------------------------------------------------------
function M:playAnim(name, mode, speed)

    mode = mode or MOAITimer.LOOP

    local anim = self.animTable[name]
    if anim then
        anim:setMode(mode)
    else
        Logger.error("cannot find anim:", name)
    end

    super.playAnim(self, name, speed)

end

function M:hitTestScreen(screenX, screenY, screenZ)

    for i, v in ipairs(self.curProps) do
        if hitTestScreen(screenX, screenY, screenZ) then
            return true
        end
    end

    return false
end

function M:hitTestWorld(screenX, screenY, screenZ)

    for i, v in ipairs(self.curProps) do
        if hitTestWorld(screenX, screenY, screenZ) then
            return true
        end
    end

    return false
end

function M:setTouchEventHandler(event, callback)
    self.eventCallback[event] = callback
end

function M:touchDownHandler(e)

    local callback = self.eventCallback[Event.TOUCH_DOWN]
    if callback and callback(e) then
        e:stop()
    end
    
end

function M:touchMoveHandler(e)

    local callback = self.eventCallback[Event.TOUCH_MOVE]
    if callback and callback(e) then
        e:stop()
    end
end

function M:touchUpHandler(e)

    local callback = self.eventCallback[Event.TOUCH_UP]
    if callback and callback(e) then
        e:stop()
    end
end


function M:addEventListeners()

    for i, v in ipairs(self.sprites) do
        v:addEventListener(Event.TOUCH_DOWN, self.touchDownHandler, self)
        v:addEventListener(Event.TOUCH_MOVE, self.touchMoveHandler, self)
        v:addEventListener(Event.TOUCH_UP,   self.touchUpHandler, self)
    end

end

return M