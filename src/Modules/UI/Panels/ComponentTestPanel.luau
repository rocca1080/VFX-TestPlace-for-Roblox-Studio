--!strict
-- 컴포넌트 테스트 패널. 속성 타입별 편집 컴포넌트를 한 곳에 모아 동작을 확인한다.
-- 필드는 Field(라벨+슬롯) + XxxInput(입력) 조합으로 구성한다.
-- 각 입력의 OnChanged는 콘솔 출력으로 반응을 확인할 수 있게 연결했다.
-- 항목 사이에는 구분선(Divider)을 넣는다.

local Components = script.Parent.Parent.Components
local ScrollPanel = require(Components.ScrollPanel)
local Label = require(Components.Label)
local Button = require(Components.Button)
local Divider = require(Components.Divider)
local Field = require(Components.Field)
local StringInput = require(Components.StringInput)
local NumberInput = require(Components.NumberInput)
local BooleanInput = require(Components.BooleanInput)
local ColorInput = require(Components.ColorInput)
local EnumInput = require(Components.EnumInput)
local SliderInput = require(Components.SliderInput)

local ComponentTestPanel = {}

function ComponentTestPanel.new(): ScrollingFrame
	-- 표시할 항목들 (구분선은 아래에서 사이사이에 자동 삽입)
	local items: { GuiObject } = {
		Label.new({ Text = "Component Test" }),
		Label.new({ Text = "Field = Label + Input (logs to console on change)" }),
		Field.new({ Label = "String", Input = StringInput.new({
			Default = "hello", OnChanged = function(v) print("[Test] String =", v) end }) }).Root,
		Field.new({ Label = "Number (0~10)", Input = NumberInput.new({
			Default = 5, Min = 0, Max = 10, OnChanged = function(v) print("[Test] Number =", v) end }) }).Root,
		Field.new({ Label = "Boolean", Input = BooleanInput.new({
			Default = true, OnChanged = function(v) print("[Test] Boolean =", v) end }) }).Root,
		Field.new({ Label = "Color3", Input = ColorInput.new({
			Default = Color3.fromRGB(61, 93, 255), Title = "Color3", OnChanged = function(v) print("[Test] Color3 =", v) end }) }).Root,
		Field.new({ Label = "Enum (LightingStyle)", Input = EnumInput.new({
			Options = { "Soft", "Realistic" }, Default = "Soft", OnChanged = function(v) print("[Test] Enum =", v) end }) }).Root,
		Field.new({ Label = "Slider (0~1)", Input = SliderInput.new({
			Default = 0.5, OnChanged = function(v) print("[Test] Slider =", v) end }) }).Root,
		Button.new({ Text = "Button", OnClick = function() print("[Test] Button clicked") end }),
	}

	-- 항목 사이에 구분선을 넣고, 전체에 순서(LayoutOrder)를 부여
	local children: { GuiObject } = {}
	local order = 0
	for i, item in items do
		order += 1
		item.LayoutOrder = order
		table.insert(children, item)
		if i < #items then
			order += 1
			table.insert(children, Divider.new({ LayoutOrder = order }))
		end
	end

	return ScrollPanel.new(children)
end

return ComponentTestPanel
