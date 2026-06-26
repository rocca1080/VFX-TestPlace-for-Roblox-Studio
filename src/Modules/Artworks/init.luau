--!strict
local Types = require(script.Types)
export type Class<Interface, Parent> = Types.Class<Interface, Parent>
export type Instance<Structure, Class> = Types.Instance<Structure, Class>
export type Event<Args...> = Types.Event<Args...>

local Artworks = {}

local ObjectOrientedProgramming = script.ObjectOrientedProgramming
Artworks.Object = require(ObjectOrientedProgramming.Object)
Artworks.class = require(ObjectOrientedProgramming.class)
Artworks.InstanceWrapper = require(ObjectOrientedProgramming.InstanceWrapper)

local EventDrivenProgramming = script.EventDrivenProgramming
Artworks.Event = require(EventDrivenProgramming.Event)
Artworks.Observer = require(EventDrivenProgramming.Observer)
Artworks.Observable = require(EventDrivenProgramming.Observable)

local DeclarativeProgramming = script.DeclarativeProgramming
Artworks.DeclarativeInstance = require(DeclarativeProgramming.DeclarativeInstance)

local EntityTagSystem = script.EntityTagSystem
Artworks.TagService = require(EntityTagSystem.TagService)
Artworks.Entity = require(EntityTagSystem.Entity)

local Utility = script.Utility
Artworks.Array = require(Utility.Array)
Artworks.Table = require(Utility.Table)
Artworks.Strings = require(Utility.Strings)
Artworks.repeatPcallUntilSuccess = require(Utility.repeatPcallUntilSuccess)

return Artworks