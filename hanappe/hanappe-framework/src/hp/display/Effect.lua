local class             = require("hp/lang/class")
local DisplayObject     = require("hp/display/DisplayObject")
local TextureDrawable   = require("hp/display/TextureDrawable")
local EffectParticle	= require("hp/display/EffectParticle")

local M = class(DisplayObject, TextureDrawable)
local super = DisplayObject

local EFFECT_TYPE_NAME = 
{
	[0] = "point",
	[1] = "area",
	[2]	= "line",
	[3]	= "ellipse",
}

local EMISSION_TYPE_NAME = 
{
	[0]	= "inwards",
	[1] = "outwards",
	[2] = "specified",
}

function M:init(maxSprite)
    DisplayObject.init(self)
	self.maxSprite = maxSprite or 32
	self.running   = false
	self.paused    = false
	self.boundsXMin = -999999
	self.boundsYMin = -999999
	self.boundsXMax = 999999
	self.boundsYMax = 999999
	self:setTouchEnabled(false)


	self.step = 1/30

	self.particles 		= {}

	self.type 			= nil --Effect Type -> 0: point, 1: area, 2: line, 3: ellipse
	self.emitAtPoints 	= nil --Emission Settings -> Grid emission
	self.maxGx			= nil --Emission Settings -> x
	self.maxGy			= nil --Emission Settings -> y
	self.emissionType	= nil --Emission Settings -> 0: inwards, 1: outwards, 2: specified
	self.ellipseArc		= nil --Emission Settings -> arc degree
	self.effectLength	= nil --Loop Settings -> Effect Length
	self.uniform		= nil --?
	self.name			= nil
	self.handleCenter	= nil --Handle -> Auto Center
	self.handleX		= nil --Handle -> X
	self.handleY		= nil --Handle -> Y
	self.traverseEdge	= nil --Edge Traversal Settings -> Travers Line
	self.endBehaviour	= nil --?
	self.distanceSetByLife = nil --Edge traversal Settings -> Distance Set By life
	self.reverseSpawnDirection = nil --Emission Settings -> Reverse Spawn Direction
	
end

function M:initSettings(attr)
	self.type 			= EFFECT_TYPE_NAME[tonumber(attr['TYPE'])]
	self.emitAtPoints 	= (attr['EMITATPOINTS'] == '1')
	self.maxGx			= tonumber(attr['MAXGX'])
	self.maxGy			= tonumber(attr['MAXGY'])
	self.emissionType	= EMISSION_TYPE_NAME[tonumber(attr['EMISSION_TYPE'])]
	self.ellipseArc		= tonumber(attr['ELLIPSE_ARC'])
	self.effectLength	= tonumber(attr['EFFECT_LENGTH'])
	self.uniform		= attr['UNIFORM']
	self.name			= attr['NAME']
	self.handleCenter	= (attr['HANDLE_CENTER'] == '1')
	self.handleX		= tonumber(attr['HANDLE_X'])
	self.handleY		= tonumber(attr['HANDLE_Y'])
	self.traverseEdge	= (attr['TRAVERSE_EDGE'] == '1')
	self.endBehaviour	= attr['END_BEHAVIOUR']
	self.distanceSetByLife = (attr['DISTANCE_SET_BY_LIFE'] == '1')
	self.reverseSpawnDirection = (attr['REVERSE_SPAWN_DIRECTION'] == '1')
end

local function getAttr(name, node, valueScl)
	valueScl = valueScl or 1
	local attrNode = node[name]
	local attr = {}
	for i, v in ipairs(attrNode) do
		local frame = tonumber(v['attributes']['FRAME'])
		local value = tonumber(v['attributes']['VALUE']) * valueScl
		table.insert(attr, {frame, value})
	end
	return attr
end

function M:initAttributes(node)

	self.angle			= getAttr('ANGLE', node, 1000)
	self.emisstionAngle = getAttr('EMISSIONANGLE', node)
	self.emisstionRange = getAttr('EMISSIONRANGE', node, 1000)
	self.areaWidth 	= getAttr('AREA_WIDTH', node)
	self.areaHeight = getAttr('AREA_HEIGHT', node)
	self.amount 	= getAttr('AMOUNT', node)
	self.life 		= getAttr('LIFE', node)
	self.sizeX 		= getAttr('SIZEX', node)
	self.sizeY 		= getAttr('SIZEY', node)
	self.velocity 	= getAttr('VELOCITY', node)
	self.weight 	= getAttr('WEIGHT', node)
	self.spin 		= getAttr('SPIN', node)
	self.alpha 		= getAttr('ALPHA', node)

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

function M:setWndBounds(xMin, yMin, xMax, yMax)
	self.boundsXMin = xMin
	self.boundsYMin = yMin
	self.boundsXMax = xMax
	self.boundsYMax = yMax
end

function M:outScreenEffect()

	local x, y, z = self:getLoc()
	local layer = self:getLayer()
	if not layer then
		return true
	end
	local wx, wy, wz = layer:worldToWnd(x, y, z)
	if wx < self.boundsXMin or wx > self.boundsXMax then
		return true
	end

	if wy < self.boundsYMin or wy > self.boundsYMax then
		return true
	end
	
	return false
end

function M:checkPause()

	local outScreen = self:outScreenEffect()
	
	for i, p in ipairs(self.particles) do
		p:pauseParticle(outScreen)
	end

	self.paused = outScreen

	return self.paused
end
function M.onTimer(timer)

	local self = timer.effect

	if self:checkPause() then
		return
	end

	local time = timer:getTimesExecuted() * self.step
	local shouldStop = false
	if self.effectLength > 0 and time * 1000 >= self.effectLength then
		shouldStop = true
	end
	
	self.ecurAngle	= self.angle and interpolate(self.angle, time) or 0
	self.ealpha 	= interpolate(self.alpha, time)
	self.espin 		= interpolate(self.spin, time)
	self.eweight 	= interpolate(self.weight, time)
	self.evelocity 	= interpolate(self.velocity, time)
	self.esizeX 	= interpolate(self.sizeX, time)
	self.esizeY 	= interpolate(self.sizeY, time)
	self.eamount 	= interpolate(self.amount, time)
	self.elife 		= interpolate(self.life, time)
	self.eareaW 	= self.areaWidth and interpolate(self.areaWidth, time)
	self.eareaH		= self.areaHeight and interpolate(self.areaHeight, time)
	self.erange		= interpolate(self.emisstionRange, time)
	self.eangle		= interpolate(self.emisstionAngle, time)

	for i, particle in ipairs(self.particles) do
		particle:setGlobalAttr(time, self)
		if not particle:isIdle() then
			shouldStop = false
		end
	end

	if shouldStop then
		self:stopParticle()
	end
end

function M:createParticles(node, textures)

	for i, v in ipairs(node) do
	--for i = #node,1, -1 do
		local v = node[i]
		local particle = EffectParticle(self.maxSprite)
		--particle:setComputeBounds(true)
		particle:setEffect(self)
		particle:setTouchEnabled(false)
		particle:createFromXmlNode(v, textures)
		table.insert(self.particles, particle)
	end
	
	local timer = MOAITimer.new()
	timer:setMode(MOAITimer.LOOP)
	timer:setSpan(self.step)
	timer.effect = self
	timer:setListener(MOAITimer.EVENT_TIMER_LOOP, M.onTimer)
	self.timer = timer
end

function M:createFromXmlNode(node, textures)
	self:initSettings(node['attributes'])
	--TODO node['children']['ANIMATION_PROPERTIES']
	self:initAttributes(node['children'])
	self:createParticles(node['children']['PARTICLE'], textures)
end



function M:startParticle()
	self.timer:start()
	M.onTimer(self.timer) --force update frame 0
	for i, particle in ipairs(self.particles) do
		particle:startParticle()
	end
	self.running = true
	self.paused = false
end

function M:stopParticle()
	if not self.running then
		return
	end

	for i, particle in ipairs(self.particles) do
		particle:stopParticle()
	end
	self.timer:stop()

	if self.stopCallback then
		self.stopCallback()
	end

	self.running = false
end

function M:setStopCallback(callback)
	self.stopCallback = callback
end

function M:setLayer(layer)
	super.setLayer(self, layer)
	local epriority = self:getPriority()
	for i, particle in ipairs(self.particles) do
		particle:setPriority(epriority + particle.layerIdx + 1)
		particle:setLayer(layer)
	end
	
	if layer and layer.getWidth and layer.getHeight then
		local width = layer:getWidth()
		local height = layer:getHeight()
		self:setWndBounds(0, 0, width, height)
	end
end


function M:dispose()
	for i, particle in ipairs(self.particles) do
		particle:dispose()
	end
	self:stopParticle()
	super.dispose(self)
end


return M

