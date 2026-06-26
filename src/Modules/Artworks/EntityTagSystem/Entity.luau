--!native
local Artworks = script.Parent.Parent
local Types = require(Artworks.Types)
local Table = require(Artworks.Utility.Table)

local ObjectOrientedProgramming = Artworks.ObjectOrientedProgramming
local Object = require(ObjectOrientedProgramming.Object)
local class = require(ObjectOrientedProgramming.class)

local EventDrivenProgramming = Artworks.EventDrivenProgramming
local Event = require(EventDrivenProgramming.Event)

local EntityTagSystem = Artworks.EntityTagSystem
local TagService = require(EntityTagSystem.TagService)



local constructor = {}

local Entity = {} :: Types.IEntity
Entity.__index = Entity

function Entity:addTag(tag)
	TagService:addTag(self, tag)
end

function Entity:getTags()
	return TagService:getTags(self)
end

function Entity:hasTag(tag)
	return TagService:hasTag(self, tag)
end

function Entity:removeTag(tag)
	TagService:removeTag(self, tag)
end

function Entity:clone()
	return constructor.from(Table.deepClone(self))
end

function Entity:destroy()
	for tag, index in self._indexes
	do
		TagService:removeTag(self, tag)
	end
	table.clear(self)
	setmetatable(self, nil)
end



function constructor.new() : Types.Entity<{}>
	return setmetatable({
		_indexes = {}
	}, Entity)
end

function constructor.from<T>(unregisteredEntity : T) : Types.Entity<T>
	local entity = setmetatable(unregisteredEntity, Entity)
	if not entity._indexes
	then
		entity._indexes = {}
	end
	TagService:_registerEntity(entity)
	
	return entity
end

return constructor