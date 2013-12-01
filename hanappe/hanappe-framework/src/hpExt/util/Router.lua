-- Router

-- import
local table             = require "hp/lang/table"
local class             = require "hp/lang/class"
local Executors         = require "hp/util/Executors"
local Event             = require "hp/event/Event"
local EventDispatcher   = require "hp/event/EventDispatcher"

-- class
-- local super             = EventDispatcher
local M                 = EventDispatcher()

function M:send( type, data )
	assert( type )

	local e = Event( type )
	e.data = data

	self:dispatchEvent( e )
end

return M