--------------------------------------------------------------------------------
-- This is a class to draw the texture. <br>
-- Base Classes => DisplayObject, TextureDrawable, Resizable <br>
--------------------------------------------------------------------------------
local table             = require("hp/lang/table")
local class             = require("hp/lang/class")
local DisplayObject     = require("hp/display/DisplayObject")
local TextureDrawable   = require("hp/display/TextureDrawable")
local Resizable         = require "hp/display/Resizable"

local M = class(DisplayObject, TextureDrawable)

M.MOAI_CLASS = MOAIParticleSystem

local ANGLE_TYPE = 
{
	[0] = "align",
	[1] = "random",
	[2] = "specify",
}
local BLEND_MODE = 
{
	[4] = {MOAIProp.GL_ONE, MOAIProp.GL_ONE},
}

local CONST = MOAIParticleScript.packConst
local REG   = MOAIParticleScript.packReg
local SCRIPT_VALUE = MOAIParticleScript.packScriptValue
local MAX_SCRIPT_PARAM = 16
--------------------------------------------------------------------------------
-- The constructor.
-- @param params (option)Parameter is set to Object.<br>
--------------------------------------------------------------------------------
function M:init(maxSprite)
    DisplayObject.init(self)
	self.maxSprite = maxSprite or 32

    local deck = MOAIGfxQuadDeck2D.new()
    
    self:setDeck(deck)
    self.deck = deck
	self.rectW = 1
	self.rectH = 1
	self.rectIdx = 1
end

function M:initSettings(attr)
	self.handleCenter = (attr['HANDLE_CENTERED'] == '1')
	if not self.handleCenter then
		self.handleX = tonumber(attr['HANDLE_X'])
		self.handleY = tonumber(attr['HANDLE_Y'])
	end

	self.angleType = ANGLE_TYPE[ tonumber(attr['ANGLE_TYPE']) ]
	self.angleOffset = tonumber(attr['ANGLE_OFFSET'])
	self.useEffectEmission = (attr['USE_EFFECT_EMISSION'] == '1')

	self.uniform	= (attr['UNIFORM'] == '1') --width, height统一一个,size
	self.oneShot	= (attr['ONE_SHOT'] == '1')
	self.single		= (attr['SINGLE_PARTICLE'] == '1')
	self.layerIdx	= tonumber(attr['LAYER'])
	self.randColor	= (attr['RANDOM_COLOR'] == '1')
	if attr['BLENDMODE'] then
		local blendMode	= BLEND_MODE[tonumber(attr['BLENDMODE'])]
		if blendMode then
			self:setBlendMode(blendMode[1], blendMode[2])
		end
	end
	self.name		= attr['NAME']
	self.relative	= (attr['RELATIVE'] == '1')
	self.lockAngle	= (attr['LOCK_ANGLE'] == '1')
	self.angleRelative= (attr['ANGLE_RELATIVE'] == '1')

	self.randomStartFrame = (attr['RANDOM_START_FRAME'] == '1')
	self.animate		  = (attr['ANIMATE'] == '1')

	Logger.debug("  create particle:", self.name)
end

function M:setEffect(effect)
	self.effect = effect
	self.effectType = effect.type
end

local function getAttr(name, node, valueScl)
	valueScl = valueScl or 1
	local attrNode = node[name]
	if not attrNode then
		return nil
	end
	local attr = {}
	for i, v in ipairs(attrNode) do
		local frame = tonumber(v['attributes']['FRAME'])
		local value = tonumber(v['attributes']['VALUE']) * valueScl
		table.insert(attr, {frame, value})
	end
	return attr
end

function M:getKeyframes(node)

	self.life 		= getAttr('LIFE', node, 1/1000)
	self.amount 	= getAttr('AMOUNT', node)
	self.baseSpeed 	= getAttr('BASE_SPEED', node)
	self.baseWeight = getAttr('BASE_WEIGHT', node)
	self.baseSizeX	= getAttr('BASE_SIZE_X', node)
	self.baseSizeY	= getAttr('BASE_SIZE_Y', node)
	self.spin		= getAttr('BASE_SPIN', node)

	self.lifeVar	= getAttr('LIFE_VARIATION', node, 1/1000)
	self.amountVar	= getAttr('AMOUNT_VARIATION', node)
	self.veloVar	= getAttr('VELOCITY_VARIATION', node)
	self.weightVar	= getAttr('WEIGHT_VARIATION', node)
	self.sizeXVar	= getAttr('SIZE_X_VARIATION', node)
	self.sizeYVar	= getAttr('SIZE_Y_VARIATION', node)
	self.spinVar	= getAttr('SPIN_VARIATION', node)
	self.motionVar	= getAttr('DIRECTION_VARIATION', node)

	self.alphaOverTime	= getAttr('ALPHA_OVERTIME', node)
	self.veloOverTime	= getAttr('VELOCITY_OVERTIME', node)
    self.weightOverTime	= getAttr('WEIGHT_OVERTIME', node)
    self.sizeXOverTime	= getAttr('SCALE_X_OVERTIME', node)
	self.sizeYOverTime	= getAttr('SCALE_Y_OVERTIME', node)
    self.spinOverTime	= getAttr('SPIN_OVERTIME', node)
	self.ROverTime		= getAttr('RED_OVERTIME', node, 1/255)
	self.GOverTime		= getAttr('GREEN_OVERTIME', node, 1/255)
	self.BOverTime		= getAttr('BLUE_OVERTIME', node, 1/255)
	self.velocityOverTime = getAttr('VELOCITY_OVERTIME', node)
	self.motionOverTime	 = getAttr('DIRECTION_VARIATIONOT', node)

	self.frameRateOverTime 	= getAttr('FRAMERATE_OVERTIME', node)
	self.globalVelocity 	= getAttr('GLOBAL_VELOCITY', node)

end

function M:createTextureSheet(tex)
	local frames = tex.frames
	local rectW, rectH = tex.rectW, tex.rectH
	local texW, texH = tex:getSize()
	self.rectW = rectW
	self.rectH = rectH
	self.frames = frames

	self:setTexture(tex)
	self.deck:reserve(frames)
	local du = rectW / texW
	local dv = rectH / texH
	local col = texW / rectW
	for i = 1, frames do
		local u1 = math.floor((i-1)% col) * du
		local v1 = math.floor((i-1)/ col) * dv
		local u2 = u1 + du
		local v2 = v1 + dv
		self.deck:setUVRect(i, u1, v1, u2, v2)
		if self.handleX and self.handleY then
			self.deck:setRect(i, -self.handleX, -self.handleY, rectW - self.handleX, rectH - self.handleY)
		else
			self.deck:setRect(i, -rectW/2, -rectH/2, rectW/2, rectH/2)
		end
	end
	
end

--load from TimeLineFX DATA.XML's node
function M:createFromXmlNode(node, textures)

	self:initSettings(node['attributes'])

	local shapeIndex = tonumber(node['children']['SHAPE_INDEX'][1]['value'])
	local tex = textures[shapeIndex]
	self:createTextureSheet(tex)

	self:getKeyframes(node['children'])
	self:setScriptReg(node)
	self.initScript = self:getInitScript(node)
	self.renderScript = self:getRenderScript(node)
	self:initSystem(node, self.initScript, self.renderScript)
end

local function interpolate(data, time)

	local t0, v0
	local kidx

	for i, v in ipairs(data) do
		local frame = v[1]
		local value = v[2]
		if time >= frame then
			t0 = frame
			v0 = value
			kidx = i
		end
	end

	if not kidx then
		return nil
	end

	local key1 = data[kidx + 1]
	if key1 then
		return v0 + ( key1[2] - v0 ) / ( key1[1] - t0 ) * (time - t0)
	else
		return v0
	end
	

	return nil
end

function transAngle(angle, rot90)
	return rot90 and angle - 90 or angle
end

function M:setGlobalAttr(time, effect)
	local deltaTime = 1 / 60
	local ealpha 	= effect.ealpha
	local espin 	= effect.espin
	local eweight 	= effect.eweight
	local evelocity = effect.evelocity
	local esizeX 	= effect.esizeX
	local esizeY 	= effect.esizeY
	local eamount 	= effect.eamount
	local elife 	= effect.elife
	local eareaW 	= effect.eareaW
	local eareaH 	= effect.eareaH
	local erange 	= effect.erange
	local eangle 	= effect.eangle
	local ecurAngle = effect.ecurAngle
	--life
	local life 		= interpolate(self.life, time)
	local lifeVar   = interpolate(self.lifeVar, time)
	local lifeMax	= life + lifeVar
	if elife then
		life 	= life * elife + 0.2  --TODO REMOVE 0.2
		lifeMax = lifeMax * elife + 0.2 --TODO REMOVE 0.2
	end
	self.state:setTerm(life, lifeMax)

	--amount
	local amount 	= interpolate(self.amount, time*1000)
	local amountVar = self.amountVar and interpolate(self.amountVar, time * 1000) or 0
	local amountMax	= amount + amountVar
	if eamount then
		amount 	  = amount * eamount 
		amountMax = amountMax * eamount
	end
	local ramount = math.random(amount, amountMax)
	self.emitter:setEmission(ramount > 0 and 1 or 0)
	if ramount > 0 then
		self.emitter:setFrequency(1/ramount, 1/ramount)
	end
	--velocity
	local velo 		= interpolate(self.baseSpeed, time*1000)
	local veloVar 	= self.veloVar and interpolate(self.veloVar, time * 1000) or 0
	local veloAdj   = self.globalVelocity and interpolate(self.globalVelocity, time * 1000) or 0
	local veloMax	= velo + veloVar
	if evelocity then
		velo 	= velo * evelocity * veloAdj
		veloMax = veloMax * evelocity * veloAdj
	end
	local rvelo = math.random(velo, veloMax)
	
	self.initScript:setScriptValue(self.scriptV['velo'], rvelo)

	--spin
	if self.angleType =="align" and self.lockAngle then
		self.initScript:setScriptValue(self.scriptV['spin'], 0)
	else
		local spin		= self.spin and interpolate(self.spin, time) or 0
		local spinVar	= self.spinVar and interpolate(self.spinVar, time) or 0
		if espin and spin then
			spin 	= spin * espin 
			spinVar = spinVar * espin
		end
		local vspin =  math.random(spin, spin + spinVar) * deltaTime
		self.initScript:setScriptValue(self.scriptV['spin'], vspin)
	end
	--deck frame
	if self.randomStartFrame then
		self.initScript:setScriptValue(self.scriptV['idx'], math.random(1, self.frames))
	end

	--size
	local sizeX 	= interpolate(self.baseSizeX, time)
	local sizeXVar	= self.sizeXVar and interpolate(self.sizeXVar, time) or 0
	if esizeX then
		sizeX 	= sizeX * esizeX 
		sizeXVar = sizeXVar * esizeX
	end
	local width = math.random(sizeX* 10000, (sizeX + sizeXVar)* 10000) / 10000
	local height = width
	if not self.uniform then
		local sizeY 	= interpolate(self.baseSizeY, time)
		local sizeYVar	= interpolate(self.sizeYVar, time)
		if esizeY then
			sizeY 	= sizeY * esizeY 
			sizeYVar = sizeYVar * esizeY
		end
		height = math.random(sizeY* 10000, (sizeY + sizeYVar)* 10000) / 10000
	end

	self:setBaseScl(width/self.rectW, height/self.rectH)


	--color
	if self.randColor then
		local rTime = math.random(0, 1000) / 1000
		local r = interpolate(self.ROverTime, rTime)
		local g = interpolate(self.GOverTime, rTime)
		local b = interpolate(self.BOverTime, rTime)
		self.initScript:setScriptValue(self.scriptV['r'], r)
		self.initScript:setScriptValue(self.scriptV['g'], g)
		self.initScript:setScriptValue(self.scriptV['b'], b)
	end

	--weight
	local weight 	= interpolate(self.baseWeight, time)
	local weightVar = self.weightVar and interpolate(self.weightVar, time) or 0
	local weightMax	= weight + weightVar
	if eweight then
		weight 	  = weight * eweight
		weightMax = weightMax * eweight
	end
	
	if self.effectType == "area" and eareaW and eareaH then
		self.emitter:setRect(-eareaW/2,-eareaH/2,eareaW/2,eareaH/2)
		self.initScript:setScriptValue(self.scriptV['areaW'], width)
		self.initScript:setScriptValue(self.scriptV['areaH'], height)
	elseif self.effectType == "line" then
		self.emitter:setRect(-eareaW/2,0,eareaW/2,0)
		self.weightMagnet:initLinear ( 0, weightMax*5 )
	elseif self.effectType == "ellipse" then
		self.emitter:setRadius(eareaW/2, eareaW/2)
		self.initScript:setScriptValue(self.scriptV['radius'], eareaW/2)
	elseif self.effectType == "point" then
		self.weightMagnet:initLinear ( 0, weightMax )
	end

	--angle
	if effect.emissionType == "specified" then
		self.initScript:setScriptValue(self.scriptV['baseRot'], transAngle(eangle, true))
	elseif self.angleType == "random" then
		self.initScript:setScriptValue(self.scriptV['baseRot'], math.random(-self.angleOffset/2, self.angleOffset/2))
	elseif self.useEffectEmission then
		local angleMin = eangle - erange
		local angleMax = eangle + erange
		local angle = math.random(angleMin, angleMax)
		if self.angleType == "random" then
			--self.initScript:setScriptValue(self.scriptV['baseRot'], angle)
		elseif self.angleType == "align" then
			angle = self.angleOffset + angle
			--self.initScript:setScriptValue(self.scriptV['baseRot'], self.angleOffset + angle - 90)
		elseif self.angleType == "specify" then
			--self.initScript:setScriptValue(self.scriptV['baseRot'], self.angleOffset)
			angle = self.angleOffset
		end
		angle = transAngle(angle, true)
		self:setBaseRot(angle)
		self.initScript:setScriptValue(self.scriptV['baseRot'], angle)
		self.emitter:setAngle(angle, angle)
	end

	ecurAngle = transAngle(ecurAngle, false)
	--emitter angle
	if self.angleRelative then
		self.initScript:setScriptValue(self.scriptV['baseRot'], ecurAngle)
	end

	--motion random
	local motionVar = self.motionVar and interpolate(self.motionVar, time)
	if motionVar and  motionVar > 0 and self.lockAngle then
		--TODO get motion!
		self.initScript:setScriptValue(self.scriptV['baseRot'], math.random(0, 360))  --方向
		self.initScript:setScriptValue(self.scriptV['velo'], math.random(5, 20))     --速度
	end

	self.emitter:setRot(0, 0, ecurAngle)
end

function M:initSystem(node, init, render)

	--weight
	local weightMagnet = MOAIParticleForce.new ()
	self.weightMagnet = weightMagnet
	--state
	local state = MOAIParticleState.new ()
	state:setTerm ( 1 )
	state:setInitScript ( init )
	state:setRenderScript ( render )
	state:pushForce ( weightMagnet )
	self.state = state
	--system
	self:reserveParticles ( self.maxSprite, MAX_SCRIPT_PARAM )
	self:reserveSprites ( 	self.maxSprite )
	self:reserveStates ( 1 )
	self:setState(1, state)
	--emitter
	local emitter = MOAIParticleTimedEmitter.new ()
	emitter:setLoc ( 0, 0 )
	emitter:setSystem ( self )
	emitter:setFrequency ( 0.016 )
	emitter:setAngle(0, self.angleOffset)

	if self.effectType == "ellipse" then
		--emitter:setRadius(1, 100)
	elseif self.effectType == "area" then
		--emitter:setRect(0,0,100,100)
	elseif self.effectType == "line" then
		weightMagnet:setType ( MOAIParticleForce.OFFSET )
	elseif self.effectType == "point" then
		weightMagnet:setType ( MOAIParticleForce.OFFSET )
	end
		
	self.emitter = emitter


	if self.relative then
		self:setParent(self.effect)
	else
		self.emitter:setParent(self.effect)
	end
end

function M:setScriptReg(node)
	self.reg = {}
	self.reg['startAngle'] 		= REG(1)
	self.reg['spinBase']		= REG(2)
	self.reg['spinOverTime']   	= REG(3)
	self.reg['rot']				= REG(4)
	self.reg['count']			= REG(5)
	self.reg['vsin']			= REG(6)
	self.reg['vcos']			= REG(7)
	self.reg['r']				= REG(8)
	self.reg['g']				= REG(9)
	self.reg['b']				= REG(10)
	self.reg['veloOT']			= REG(11)
	self.reg['velo']			= REG(12)
	self.reg['velodx']			= REG(13)
	self.reg['velody']			= REG(14)
	self.reg['idx']				= REG(15)
	

	self.scriptV = {}
	self.scriptV['areaW']			= SCRIPT_VALUE(1)
	self.scriptV['areaH']			= SCRIPT_VALUE(2)
	self.scriptV['radius']			= SCRIPT_VALUE(3)
	self.scriptV['vel']				= SCRIPT_VALUE(4)
	self.scriptV['r']				= SCRIPT_VALUE(5)
	self.scriptV['g']				= SCRIPT_VALUE(6)
	self.scriptV['b']				= SCRIPT_VALUE(7)
	self.scriptV['spin']			= SCRIPT_VALUE(8)
	self.scriptV['baseRot']			= SCRIPT_VALUE(9)
	self.scriptV['velo']			= SCRIPT_VALUE(10)
	self.scriptV['idx']				= SCRIPT_VALUE(11)
end

function M:getInitScript(node)
	local init = MOAIParticleScript.new ()
	init:set(self.reg['rot'], self.scriptV['baseRot'])
	init:set(self.reg['idx'], self.scriptV['idx'])
	
	if self.effect.emitAtPoints then
		if self.effectType == 'ellipse' then
			local arc = self.effect.ellipseArc
			local delta = arc/self.effect.maxGx
			init:count(self.reg['count'])
			init:mul(self.reg['count'], self.reg['count'], CONST(delta))
			init:angleVec(self.reg['vsin'], self.reg['vcos'], self.reg['count'])
			init:mul(MOAIParticleScript.PARTICLE_Y, self.reg['vsin'], self.scriptV['radius'])
			init:mul(MOAIParticleScript.PARTICLE_X, self.reg['vcos'], self.scriptV['radius'])
		elseif self.effectType == 'area' then

		elseif self.effectType == 'line' then

		end
	end
	
	init:set(self.reg['r'], self.scriptV['r'])
	init:set(self.reg['g'], self.scriptV['g'])
	init:set(self.reg['b'], self.scriptV['b'])

	init:set(self.reg['spinBase'], self.scriptV['spin'])
	init:set(self.reg['velo'], self.scriptV['velo'])
	init:angleVec(self.reg['velodx'], self.reg['velody'], self.scriptV['baseRot'])
	--init:mul(self.reg['velodx'], self.reg['velodx'], self.scriptV['velo'])
	--init:mul(self.reg['velody'], self.reg['velody'], self.scriptV['velo'])
	--init:set(self.reg['veloBase'], self.scriptV['velo'])

	init:setScriptValue(self.scriptV['idx'], 1)

	return init
end

local function table2dto1D(t2d)
	local tt = ""

	tt = tt .. string.pack('b', #t2d * 2 * 4)

	for i, v in ipairs(t2d) do
		tt = tt .. string.pack('f', v[1])
		tt = tt .. string.pack('f', v[2])
	end
	return tt
end

function M:renderColor(render)
	if not self.randColor then
		--red
		local nRKey	 = #self.ROverTime
		if nRKey > 1 then
			local r  = table2dto1D(self.ROverTime)
			render:easeKeys(MOAIParticleScript.SPRITE_RED, r, MOAIEaseType.LINEAR)
		elseif nRKey == 1 then
			render:set(MOAIParticleScript.SPRITE_RED, CONST(self.ROverTime[1][2]))
		end
		
		--green
		local nGKey	 = #self.GOverTime
		if nGKey > 1 then
			local g = table2dto1D(self.GOverTime)
			render:easeKeys(MOAIParticleScript.SPRITE_GREEN, g, MOAIEaseType.LINEAR)
		elseif nGKey == 1 then
			render:set(MOAIParticleScript.SPRITE_GREEN, CONST(self.GOverTime[1][2]))
		end
		
		--blue
		local nBKey	 = #self.BOverTime
		if nBKey > 1 then
			local b  = table2dto1D(self.BOverTime)
			render:easeKeys(MOAIParticleScript.SPRITE_BLUE, b, MOAIEaseType.LINEAR)
		elseif nBKey == 1 then
			render:set(MOAIParticleScript.SPRITE_BLUE, CONST(self.BOverTime[1][2]))
		end
	else
		render:set(MOAIParticleScript.SPRITE_RED, 	self.reg['r'])
		render:set(MOAIParticleScript.SPRITE_GREEN, self.reg['g'])
		render:set(MOAIParticleScript.SPRITE_BLUE, 	self.reg['b'])
	end
end

function M:getRenderScript(node)
	local render = MOAIParticleScript.new ()
	render:sprite()

	render:set(MOAIParticleScript.SPRITE_ROT, self.reg['rot'])
	render:set(MOAIParticleScript.SPRITE_IDX, self.reg['idx'])
	--alpha
	local nAlphaKey = #self.alphaOverTime
	if nAlphaKey > 1 then
		local alpha  = table2dto1D(self.alphaOverTime)
		render:easeKeys(MOAIParticleScript.SPRITE_OPACITY, alpha, MOAIEaseType.LINEAR)
	elseif nAlphaKey == 1 then
		render:set(MOAIParticleScript.SPRITE_OPACITY, CONST(self.alphaOverTime[1][2]))
	end
		--scale
	local scaleX  = table2dto1D(self.sizeXOverTime)
	render:easeKeys(MOAIParticleScript.SPRITE_X_SCL, scaleX, MOAIEaseType.LINEAR)
	local scaleY = scaleX
	if not self.uniform then
		scaleY  = table2dto1D(self.sizeYOverTime)
	end
	render:easeKeys(MOAIParticleScript.SPRITE_Y_SCL, scaleY, MOAIEaseType.LINEAR)
	--rot
    local nSpinKey = #self.spinOverTime                                                            
    if nSpinKey > 1 then                                                          
        local rot = table2dto1D(self.spinOverTime)                                                 
        render:easeKeys(self.reg['spinOverTime'], rot, MOAIEaseType.LINEAR)                        
        render:mul(self.reg['spinOverTime'], self.reg['spinOverTime'], self.reg['spinBase'])       
        render:add(self.reg['rot'], self.reg['rot'], self.reg['spinOverTime'])                     
        render:set(MOAIParticleScript.SPRITE_ROT, self.reg['rot'])                                 
    elseif nSpinKey == 1 then                                                                      
        render:mul(self.reg['spinOverTime'],  CONST(self.spinOverTime[1][2]), self.reg['spinBase'])
        render:add(self.reg['rot'], self.reg['rot'], self.reg['spinOverTime'])                     
        render:set(MOAIParticleScript.SPRITE_ROT, self.reg['rot'])                                 
    else                                              
        render:add(self.reg['rot'], self.reg['rot'],  self.reg['spinBase'])                        
        render:set(MOAIParticleScript.SPRITE_ROT, self.reg['rot'])                                 
    end                                                       
	--velocity
	local nVelo = #self.velocityOverTime
	
	if nVelo > 1 then
		local velo = table2dto1D(self.velocityOverTime)
		render:easeKeys(self.reg['veloOT'], velo, MOAIEaseType.LINEAR)
		render:mul(self.reg['velo'], self.reg['veloOT'], self.reg['velo'])
		render:mul(MOAIParticleScript.PARTICLE_DX, self.reg['velodx'], self.reg['velo'])
		render:mul(MOAIParticleScript.PARTICLE_DY, self.reg['velody'], self.reg['velo'])
	elseif nVelo == 1 then
		render:set(self.reg['veloOT'], CONST(self.spinOverTime[1][2]))
		render:mul(self.reg['velo'], self.reg['veloOT'], self.reg['velo'])
		render:mul(MOAIParticleScript.PARTICLE_DX, self.reg['velodx'], self.reg['velo'])
		render:mul(MOAIParticleScript.PARTICLE_DY, self.reg['velody'], self.reg['velo'])
	end
	--color
	self:renderColor(render)

	return render
end

function M:dispose()
	self.emitter:stop()
	self:stop()
end

function M:startParticle()
	self:start ()
	if self.oneShot and self.single then
		self.emitter:surge(1)
	else
		self.emitter:start()
	end
end

function M:stopParticle()
    self.emitter:stop()
end

function M:pauseParticle(isPaused)
	self:pause(isPaused)
    self.emitter:pause(isPaused)
end


return M

