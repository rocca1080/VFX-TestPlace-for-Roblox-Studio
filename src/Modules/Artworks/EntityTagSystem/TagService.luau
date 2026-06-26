--!native
local Artworks = script.Parent.Parent
local Types = require(Artworks.Types)
local Array = require(Artworks.Utility.Array)

local ObjectOrientedProgramming = Artworks.ObjectOrientedProgramming
local Object = require(ObjectOrientedProgramming.Object)
local class = require(ObjectOrientedProgramming.class)

local EventDrivenProgramming = Artworks.EventDrivenProgramming
local Event = require(EventDrivenProgramming.Event)

local entitiesByTag = {}
local entityAddedEvents = {}
local entityRemovedEvents = {}

local methods = {} :: Types.IEntityTagService

function methods:getAllTags()
	local tags = {}
	for tag, entities in entitiesByTag
	do
		table.insert(tags, tag)
	end
	
	return tags
end

function methods:getEntityAddedEvent(tag)
	local event = entityAddedEvents[tag]
	if event == nil
	then
		event = Event.new()
		entityAddedEvents[tag] = event
	end
	
	return event
end

function methods:getEntityRemovedEvent(tag)
	local event = entityRemovedEvents[tag]
	if event == nil
	then
		event = Event.new()
		entityRemovedEvents[tag] = event
	end
	
	return event
end

function methods:getTaggedEntities(tag)
	return entitiesByTag[tag] or {}
end

function methods:addTag(entity, tag)
	local index = entity._indexes[tag]
	if not index
	then
		local entities = entitiesByTag[tag]
		if entities == nil
		then
			entities = {}
			entitiesByTag[tag] = entities
			self.tagAdded:fire(tag)
		end
		
		entity._indexes[tag] = Array.insertLast(entities, entity)
		if entityAddedEvents[tag]
		then
			entityAddedEvents[tag]:fire(entity)
		end
	end
end

function methods:getTags(entity)
	local tags = {}
	for tag, index in entity._indexes do
		table.insert(tags, tag)
	end
	return tags
end

function methods:hasTag(entity, tag)
	return self._indexes[tag] ~= nil
end

function methods:removeTag(entity, tag)
	local index = entity._indexes[tag]
	if index
	then
		local entities = entitiesByTag[tag]
		local index = entity._indexes[tag]
		entity._indexes[tag] = nil
		
		local swappedEntity = Array.swapRemove(entities, index)
		if swappedEntity
		then
			swappedEntity._indexes[tag] = index
		end
		
		if entityRemovedEvents[tag]
		then
			entityRemovedEvents[tag]:fire(entity)
		end
		
		if #entities == 0
		then
			entitiesByTag[tag] = nil
			self.tagRemoved:fire(tag)
		end
	end
end

function methods:_registerEntity(entity)
	for tag, index in ipairs(entity._indexes)
	do
		if not entitiesByTag[tag]
		then
			entitiesByTag[tag] = {}
			self.tagAdded:fire(tag)
		end
		
		entity._indexes[tag] = Array.insertLast(entitiesByTag[tag], entity)
		if entityAddedEvents[tag]
		then
			entityAddedEvents[tag]:fire(entity)
		end
	end
end

local EntityTagService = class(methods)
return EntityTagService({tagAdded = Event.new(), tagRemoved = Event.new()}) :: Types.TagService