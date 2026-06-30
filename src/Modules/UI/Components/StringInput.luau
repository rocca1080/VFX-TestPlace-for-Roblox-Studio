--!strict
-- 문자열 입력 컨트롤(라벨 없음). Field에 끼워서 사용한다.
-- 반환: { Root, GetValue, SetValue } (Root = TextBox, Size(1,1) → Field에서 반반 채움)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme

export type StringInputProps = {
	Default: string?,
	OnChanged: ((value: string) -> ())?,
}

export type StringInput = {
	Root: TextBox,
	GetValue: () -> string,
	SetValue: (value: string) -> (),
}

local StringInput = {}

function StringInput.new(props: StringInputProps): StringInput
	local value = props.Default or ""

	local input = DI.TextBox({
		Name = "StringInput",
		Text = value,
		PlaceholderText = "...",
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

	local function setValue(v: string)
		value = v
		input.Text = value
		if props.OnChanged then props.OnChanged(value) end
	end

	input.FocusLost:Connect(function()
		value = input.Text
		if props.OnChanged then props.OnChanged(value) end
	end)

	return {
		Root = input,
		GetValue = function() return value end,
		SetValue = setValue,
	}
end

return StringInput
