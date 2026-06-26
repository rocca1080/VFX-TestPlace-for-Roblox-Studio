--!strict
local Artworks = script.Parent.Parent

local ObjectOrientedProgramming = Artworks.ObjectOrientedProgramming
local class = require(ObjectOrientedProgramming.class)
local Object = require(ObjectOrientedProgramming.Object)



local methods = {}

-- Disconnects the connection.
function methods:disconnect()
	if self.connected
	then
		self._callbacks[self] = nil
		self.connected = false
	end
end



local Connection = class(methods, Object.class)
local constructor = {class = Connection}

-- Returns a new connection instance.
function constructor.new(callbacks, callback)
	local connection = Connection(Object.new(), {
		_callbacks = callbacks,
		connected = true
	})
	
	callbacks[connection] = callback
	
	return connection
end

return constructor
