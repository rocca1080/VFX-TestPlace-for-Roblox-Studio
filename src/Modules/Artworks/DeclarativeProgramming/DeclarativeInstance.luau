local ReflectionService = game:GetService("ReflectionService")

local Artworks = script.Parent.Parent

local EventDrivenProgramming = Artworks.EventDrivenProgramming
local Observable = require(EventDrivenProgramming.Observable)
local Observer = require(EventDrivenProgramming.Observer)

type from<Instance> = <Children>(Instance & Children) -> (Instance & Children)

local reflectedPropertyTypes : {[string] : string} = {}

local function getPropertyTypes(className)
	if not reflectedPropertyTypes[className] then
		local properties = {}
		for index, propertyInfo in ReflectionService:GetPropertiesOfClass(className) do
			properties[propertyInfo.Name] = propertyInfo.Type.ScriptType
		end
		for index, eventInfo in ReflectionService:GetEventsOfClass(className) do
			properties[eventInfo.Name] = "RBXScriptSignal"
		end
		reflectedPropertyTypes[className] = properties
	end

	return reflectedPropertyTypes[className]
end

local function bind(instance : Instance, binding : {any}, assignValue : (value : any) -> ())
	local object = binding[1]
	local property = binding[2]
	local transform = binding[3] or function(value)
		return value
	end
	local callback = function(value)
		assignValue(transform(value))
	end

	local subscription
	if typeof(object) == "table" then
		subscription = Observer:subscribeKey(object, property, callback)
	elseif typeof(object) == "Instance" then
		if getPropertyTypes(object.ClassName)[property] then
			subscription = Observer:subscribeProperty(object, property, callback)
		else
			subscription = Observer:subscribeAttribute(object, property, callback)
		end
	else
		error("Type of object must be table or Instance.", 4)
	end

	instance.Destroying:Connect(function()
		subscription:unsubscribe()
	end)
end

local function assign(instance : Instance, key : string | number, value : any)
	local typeOfKey = typeof(key)
	local typeOfValue = typeof(value)

	if typeOfKey == "string" then
		local propertyTypes = getPropertyTypes(instance.ClassName)
		local propertyType = propertyTypes[key]

		if propertyType ~= nil then	-- isProperty
			if propertyType == "RBXScriptSignal" then
				if typeOfValue ~= "function" then
					error("Only functions can be assigned to events.", 3)
				end

				instance[key]:Connect(value)
			else
				if (propertyType == typeOfValue) or ((propertyType == "string") and (typeOfValue == "number")) then
					instance[key] = value
				elseif typeOfValue == "table" then
					bind(instance, value, function(value)
						instance[key] = value
					end)
				else
					error("Can't assign property " .. tostring(key) .. " of type " .. propertyType .. " with value " .. tostring(value) .. " of type " .. typeof(value) .. ".", 3)
				end
			end
		else
			if typeOfValue == "Instance" then
				value.Name = key
				value.Parent = instance
			elseif typeOfValue == "table" then
				bind(instance, value, function(value)
					instance:SetAttribute(key, value)
				end)
			else
				instance:SetAttribute(key, value)
			end
		end
	elseif typeOfKey == "number" then
		if typeOfValue == "Instance" then
			value.Parent = instance
		elseif typeOfValue == "string" then
			instance:AddTag(value)
		else
			error("Invalid value type.", 3)
		end
	end
end

local function apply<T, U>(instance : T, properties : U) : T & U
	for key, value in properties or {}
	do
		assign(instance, key, value)
	end

	return instance :: T & U
end

local constructor = {}

local function new<ClassName>(className : ClassName | keyof<UIInstances>) : from<index<UIInstances, ClassName>>
	return function(properties)
		local instance = Instance.new(className)

		return apply(instance, properties)
	end
end

constructor.new = new

function constructor.from<Instance>(instance : Instance) : from<Instance>
	return function(properties)
		local clone = instance:Clone()

		return apply(clone, properties)
	end
end

function constructor.reactiveValue(subject : {[string] : any} | Instance, key : string, callback)
	return {subject, key, callback}
end

constructor.apply = apply

constructor.BillboardGui = new("BillboardGui")
constructor.ScreenGui = new("ScreenGui")
constructor.SurfaceGui = new("SurfaceGui")

constructor.CanvasGroup = new("CanvasGroup")
constructor.Frame = new("Frame")
constructor.ScrollingFrame = new("ScrollingFrame")
constructor.VideoFrame = new("VideoFrame")
constructor.ViewportFrame = new("ViewportFrame")

constructor.ImageButton = new("ImageButton")
constructor.ImageLabel = new("ImageLabel")

constructor.TextBox = new("TextBox")
constructor.TextButton = new("TextButton")
constructor.TextLabel = new("TextLabel")

constructor.UIGridLayout = new("UIGridLayout")
constructor.UIListLayout = new("UIListLayout")
constructor.UIPageLayout = new("UIPageLayout")
constructor.UITableLayout = new("UITableLayout")

constructor.UICorner = new("UICorner")
constructor.UIDragDetector = new("UIDragDetector")
constructor.UIFlexItem = new("UIFlexItem")
constructor.UIGradient = new("UIGradient")
constructor.UIPadding = new("UIPadding")
constructor.UIScale = new("UIScale")
constructor.UIShadow = new("UIShadow")
constructor.UIStroke = new("UIStroke")

constructor.UIAspectRatioConstraint = new("UIAspectRatioConstraint")
constructor.UISizeConstraint = new("UISizeConstraint")
constructor.UITextSizeConstraint = new("UITextSizeConstraint")

constructor.StyleLink = new("StyleLink")

type UIInstances = {
	BillboardGui : BillboardGui,
	ScreenGui : ScreenGui,
	SurfaceGui : SurfaceGui,

	CanvasGroup : CanvasGroup,
	Frame : Frame,
	ScrollingFrame : ScrollingFrame,
	VideoFrame : VideoFrame,
	ViewportFrame : ViewportFrame,

	ImageButton : ImageButton,
	ImageLabel : ImageLabel,

	TextBox : TextBox,
	TextButton : TextButton,
	TextLabel : TextLabel,

	UIGridLayout : UIGridLayout,
	UIListLayout : UIListLayout,
	UIPageLayout : UIPageLayout,
	UITableLayout : UITableLayout,

	UICorner : UICorner,
	UIDragDetector : UIDragDetector,
	UIFlexItem : UIFlexItem,
	UIGradient : UIGradient,
	UIPadding : UIPadding,
	UIScale : UIScale,
	UIShadow : UIShadow,
	UIStroke : UIStroke,

	UIAspectRatioConstraint : UIAspectRatioConstraint,
	UISizeConstraint : UISizeConstraint,
	UITextSizeConstraint : UITextSizeConstraint,

	StyleLink : StyleLink,
}

return constructor
