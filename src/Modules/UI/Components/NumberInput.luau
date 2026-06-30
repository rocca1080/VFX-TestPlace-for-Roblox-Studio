--!strict
-- 숫자 입력 컨트롤(라벨 없음). Min/Max를 주면 그 범위로 클램프. 숫자 아닌 입력은 이전 값으로 복구.
-- 반환: { Root, GetValue, SetValue } (Root = TextBox, Size(1,1) → Field에서 반반 채움)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme

export type NumberInputProps = {
	Default: number?,
	Min: number?,
	Max: number?,
	OnChanged: ((value: number) -> ())?,
}

export type NumberInput = {
	Root: TextBox,
	GetValue: () -> number,
	SetValue: (value: number) -> (),
}

local NumberInput = {}

function NumberInput.new(props: NumberInputProps): NumberInput
	local function clampToRange(n: number): number
		if props.Min then n = math.max(n, props.Min) end
		if props.Max then n = math.min(n, props.Max) end
		return n
	end

	local value = clampToRange(props.Default or 0)

	local input = DI.TextBox({
		Name = "NumberInput",
		Text = tostring(value),
		PlaceholderText = "0",
		ClearTextOnFocus = false,
		Size = UDim2.fromScale(1, 1),
		"Input",
		DI.UICorner({ CornerRadius = Theme.dim.corner }),
		DI.UIPadding({
			PaddingLeft = UDim.new(0, Theme.dim.inputPadding),
			PaddingRight = UDim.new(0, Theme.dim.inputPadding),
		}),
	})
	input.TextXAlignment = Enum.TextXAlignment.Left

	local function setValue(n: number)
		value = clampToRange(n)
		input.Text = tostring(value)
		if props.OnChanged then props.OnChanged(value) end
	end

	input.FocusLost:Connect(function()
		local parsed = tonumber(input.Text)
		if parsed then
			setValue(parsed)
		else
			input.Text = tostring(value) -- 숫자가 아니면 이전 값으로 복구
		end
	end)

	return {
		Root = input,
		GetValue = function() return value end,
		SetValue = setValue,
	}
end

return NumberInput
