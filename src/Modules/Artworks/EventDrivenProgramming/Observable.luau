--!strict
local Artworks = script.Parent.Parent
local Types = require(Artworks.Types)

local EventDrivenProgramming = Artworks.EventDrivenProgramming
local Event = require(EventDrivenProgramming.Event)

local Table = require(Artworks.Utility.Table)



local methods = {} :: Types.IObservable

-- Returns a property changed event of the property.
function methods:getPropertyChangedEvent(property)
	if not self._propertyChangedEvents[property]
	then
		self._propertyChangedEvents[property] = Event.new()
	end
	return self._propertyChangedEvents[property]
end

-- Converts the instance into an observable.
local function Observable<T>(instance : T?) : Types.Observable<T>
	instance = instance or {}
	local clone = table.clone(instance)
	setmetatable(clone, getmetatable(instance))
	table.clear(instance)

	instance.changed = Event.new()
	instance._propertyChangedEvents = {}
	instance.getPropertyChangedEvent = methods.getPropertyChangedEvent

	instance.changed:connect(function(key, value)
		if instance._propertyChangedEvents[key]
		then
			instance._propertyChangedEvents[key]:fire(value)
		end
	end)

	local metatable = {} :: Types.Metatable
	metatable.__index = clone
	metatable.__newindex = function(self, key, value)
		if metatable.__index[key] ~= value
		then
			metatable.__index[key] = value
			self.changed:fire(key, value)
		end
	end
	metatable.__call = function()
		return clone
	end
	metatable.__tostring = function()
		return Table.toString(clone)
	end
	metatable.__metatable = getmetatable(clone) or "nil"
	metatable.__len = function()
		return #clone
	end
	metatable.__iter = function()
		return next, clone
	end

	return setmetatable(instance, metatable)
end

return Observable
