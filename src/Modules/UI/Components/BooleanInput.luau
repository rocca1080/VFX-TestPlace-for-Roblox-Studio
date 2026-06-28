--!strict
-- 불리언 입력 컨트롤(라벨 없음) = 체크박스. Field에 끼워서 사용.
--   Root = 체크박스 버튼, Size(1,1)+SizeConstraint=RelativeYY → 높이 기준 정사각형 유지
--   (Field의 가로 Fill에서 이름이 나머지 공간을 채움)
-- 반환: { Root, GetValue, SetValue }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

export type BooleanInputProps = {
	Default: boolean?,
	OnChanged: ((value: boolean) -> ())?,
}

export type BooleanInput = {
	Root: TextButton,
	GetValue: () -> boolean,
	SetValue: (value: boolean) -> (),
}

local BooleanInput = {}

function BooleanInput.new(props: BooleanInputProps): BooleanInput
	local value = props.Default or false

	-- 체크 표시 (값이 true일 때만 보임)
	local mark = DI.Frame({
		Name = "Mark",
		Size = UDim2.fromScale(0.6, 0.6),
		Position = UDim2.fromScale(0.2, 0.2),
		"CheckMark",
		DI.UICorner({ CornerRadius = UDim.new(0, 3) }),
	})
	mark.Visible = value

	local box = DI.TextButton({
		Name = "BooleanInput",
		Text = "",
		AutoButtonColor = true,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		"Checkbox",
		DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
		mark,
	})

	local function setValue(v: boolean)
		value = v
		mark.Visible = value
		if props.OnChanged then props.OnChanged(value) end
	end

	box.Activated:Connect(function()
		setValue(not value)
	end)

	return {
		Root = box,
		GetValue = function() return value end,
		SetValue = setValue,
	}
end

return BooleanInput
