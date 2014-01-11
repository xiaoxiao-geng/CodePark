local string = require "hp/lang/string"
local Effect = require "hp/display/Effect"
local class  = require "hp/lang/class"

local M = class()


function M:init(maxSprite)
	self.xmlPath 		= nil
	self.textureRoot 	= nil
	self.maxSprite		= maxSprite or 32
	self.createOnLoad	= false
end
--load from .eff(zip), 
--.eff file extract to effRoot
function M:loadFromEff(xmlPath, textureRoot, createOnLoad)

	assert(xmlPath)
	assert(textureRoot)
	
	self.xmlPath	 = xmlPath
	self.textureRoot = textureRoot
	self.createOnLoad= createOnLoad
	
	local xml = MOAIXmlParser.parseFile(xmlPath)
	self:parseShapes(xml.children['SHAPES'])
	self.xml = xml

	local effects = {}
	if self.createOnLoad then
		if xml.children['FOLDER'] then
		 	effects = self:parseFolders(xml.children['FOLDER'])
		 else
		 	for i, v in ipairs(xml.children['EFFECT']) do
		 		local name = v['attributes']['NAME']
		 		effects[name] = self:createEffect(v)
		 	end
		 end
	end
	self.effects = effects
end

function M:parseShapes(data)
	local textures = {}
	local images = data[1]['children']['IMAGE']
	for i, v in ipairs(images) do
		local attr = v['attributes']
		local tex = self:createTexture(attr)
		local idx = tonumber(attr['INDEX'])
		tex.frames = tonumber(attr['FRAMES'])
		tex.rectW = tonumber(attr['WIDTH'])
		tex.rectH = tonumber(attr['HEIGHT'])
		textures[idx] = tex
	end
	self.textures = textures
end

function M:createTexture(attr)
	local imgPath = attr['URL']
	local idx = 0
	local idxFind = nil
	while true do
		idx = string.find(imgPath, "[/|\\]", idx + 1)
		if not idx or idx < 0 then
			break
		else
			idxFind = idx + 1
		end
	end
	local path = imgPath
	if idxFind then
		path = string.sub(imgPath, idxFind)
	end
	path = string.format("%s/%s", self.textureRoot, path)
	local tex = TextureManager:request(path)
	return tex
end

function M:parseFolders(data, findName)
	local effects = {}
	for i, v in ipairs(data) do
		local folderName = v['attributes']['NAME']
		for k, v in pairs(v['children']['EFFECT']) do
			local effectName = v['attributes']['NAME']
			local name = string.format("%s/%s", folderName, effectName)
			if findName then
				if findName == name then
					effects[name] = self:createEffect(v)
					break
				end
			else
				effects[name] = self:createEffect(v)
			end
		end
	end
	return effects
end

function M:createEffect(node)
	local effect = Effect(self.maxSprite)
	effect:createFromXmlNode(node, self.textures)
	return effect
end

function M:createEffectByName(name)
	local xml = self.xml
	local effect = nil
	if xml.children['FOLDER'] then
		local effects = self:parseFolders(xml.children['FOLDER'], name)
		effect = effects[name]
	 else
		for i, v in ipairs(xml.children['EFFECT']) do
			local nodeName = v['attributes']['NAME']
			if name and name == nodeName then
				effect = self:createEffect(v)
			end
		end
	end
	return effect
end

--name: foldername/effectname
function M:getEffect(name)

	if not self.effects[name] then
		self.effects[name] = self:createEffectByName(name)
	end

	return self.effects[name]
end

function M:dispose()
	for i, effect in pairs(self.effects) do
		effect:dispose()
	end
	self.effects = {}
end

return M
