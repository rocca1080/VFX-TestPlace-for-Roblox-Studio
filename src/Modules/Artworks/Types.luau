--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type Key = string
export type Value = any
export type Table = {[any] : any}
export type Array<T> = {[number] : T}
export type Function<Args..., Rets...> = (Args...) -> Rets...
export type Iterator = (state: any, current: any) -> (any, any)
export type Callback<Args..., Rets...> = { f: (Args...) -> Rets... }
export type Metatable = {
	__index : ((self : Table, index : any) -> any) | Table,
	__newindex : (self : Table, index : any, value : any) -> nil,
	__call : (self : Table, ...any) -> ...any,
	__concat : (self : Table, value : any) -> any,
	__unm : (self : Table) -> any,
	__add : (self : Table, value : any) -> any,
	__sub : (self : Table, value : any) -> any,
	__mul : (self : Table, value : any) -> any,
	__div : (self : Table, value : any) -> any,
	__idiv : (self : Table, value : any) -> any,
	__mod : (self : Table, value : any) -> any,
	__pow : (self : Table, value : any) -> any,
	__tostring : (self : Table) -> string,
	__metatable : any,
	__eq : (self : Table, value : any) -> boolean,
	__lt : (self : Table, value : any) -> boolean,
	__le : (self : Table, value : any) -> boolean,
	__mode : "k" | "v" | "kv",
	__len : (self : Table) -> number,
	__iter : (self : Table) -> (Iterator, any, any),
}


export type Structure = {[string] : any}
export type Interface = {[string] : Function<...any>}

export type Class<Interface, Parent> = typeof(setmetatable({} :: Interface, {__index = {} :: Parent}))
	-- __call : (Structure) -> Instance<Structure, Class<Structure, Interface, Parent>>
export type Instance<Structure, Class> = typeof(setmetatable({} :: Structure, {__index = {} :: Class}))



export type IObject = Class<{
	isInstanceOf : (self : any, class : Class<any, any>) -> boolean
}, nil>

export type Object = Instance<{}, IObject>

export type IEvent<Args...> = Class<{
	fire : (self : any, Args...) -> (),
	connect : (self : any, Function<Args...>) -> (Connection),
	wait : (self : any) -> Args...,
	once : (self : any, Function<Args...>) -> (Connection),
}, IObject>

export type Event<Args...> = Instance<{}, IEvent<Args...>>

export type IConnection = Class<{
	disconnect : (self : any) -> ()
}, IObject>

export type Connection = Instance<{
	Connected : boolean
}, IConnection>

export type IObservable = {
	changed : Event<Key, Value>,
	getPropertyChangedEvent : (self : any, property : string) -> Event<Value>
}

export type Observable<T> = IObservable & T -- Instance<IObservable, T>

export type ITagService<Tag> = Class<{
	getAllTags : (self : TagService<Tag>) -> {Tag},
	getEntityAddedEvent : (self : TagService<Tag>, tag : Tag) -> Event<Entity<Tag>>,
	getEntityRemovedEvent : (self : TagService<Tag>, tag : Tag) -> Event<Entity<Tag>>,
	getTaggedEntities : (self : TagService<Tag>, tag : Tag) -> {Entity<Tag>},
	
	addTag : (self : TagService<Tag>, entity : Entity<Tag>, tag : Tag) -> (),
	getTags : (self : TagService<Tag>, entity : Entity<Tag>) -> {Tag},
	hasTag : (self : TagService<Tag>, entity : Entity<Tag>, tag : Tag) -> boolean,
	removeTag : (self : TagService<Tag>, entity : Entity<Tag>, tag : Tag) -> (),
}, nil>

export type TagService<Tag> = Instance<{
	tagAdded : Event<Tag>,
	tagRemoved : Event<Tag>,
}, ITagService<Tag>>

export type IEntity<Tag> = Class<{
	addTag : (self : Entity<Tag>, tag : Tag) -> (),
	getTags : (self : Entity<Tag>) -> {Tag},
	hasTag : (self : Entity<Tag>, tag : Tag) -> boolean,
	removeTag : (self : Entity<Tag>, tag : Tag) -> (),

	clone : (self : Entity<Tag>) -> Entity<Tag>,
	destroy : (self : Entity<Tag>) -> (),
}, nil>

export type Entity<Tag> = Instance<any, IEntity<Tag>>

return nil