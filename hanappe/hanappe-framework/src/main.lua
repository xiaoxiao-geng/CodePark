local DisplayObject = require "hp/display/DisplayObject"
DisplayObject.sayHi = function( self ) print("hi i'm ", self) end
DisplayObject.getFullPos = function( self )
	local parent = self:getParent()
	if parent then
		local px, py = parent:getFullPos()
		local x, y = self:getPos()
		return x + px, y + py
	else
		return self:getPos()
	end
end

print("main begin")
print("DisplayObject", DisplayObject)
print("DisplayObject.sayHi", DisplayObject.sayHi)

-- import
print("require modules")
local modules = require "modules"
local config = require "config"

-- start and open
Application:start(config)
SceneManager:openScene(config.mainScene)

local DisplayObject = require "hp/display/DisplayObject"

print("DisplayObject", DisplayObject)
print("DisplayObject.sayHi", DisplayObject.sayHi)

print( "main end" )