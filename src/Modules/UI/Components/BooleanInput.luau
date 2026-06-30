--!strict
-- 불리언 입력 컨트롤(라벨 없음) = 체크박스. Field에 끼워서 사용.
--   Root = 체크박스 버튼, Size(1,1)+SizeConstraint=RelativeYY → 높이 기준 정사각형 유지
--   (Field의 가로 Fill에서 이름이 나머지 공간을 채움)
-- 반환: { Root, GetValue, SetValue }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme
local Icons = require(script.Parent.Parent.Styles.Icons)

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

	-- 체크 아이콘 (닫기 버튼과 동일한 삽입 형태: 버튼 안에 UIPadding + "Icon" ImageLabel)
	-- 항상 표시하고 색만 바꾼다 → 활성: 아이콘 text 색 / 비활성: 아이콘 inputText 색
	local imagePadding = Theme.dim.imagePadding
	local checkIcon = DI.ImageLabel({
		Name = "Icon",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		"Icon",
	})
	checkIcon.Image = Icons.check

	local box = DI.TextButton({
		Name = "BooleanInput",
		Text = "",
		AutoButtonColor = true,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		"Checkbox",
		DI.UICorner({ CornerRadius = Theme.dim.corner }),
		DI.UIPadding({
			PaddingLeft = UDim.new(0, imagePadding),
			PaddingRight = UDim.new(0, imagePadding),
			PaddingTop = UDim.new(0, imagePadding),
			PaddingBottom = UDim.new(0, imagePadding),
		}),
		checkIcon,
	})

	-- 값에 따라 배경색/아이콘색 갱신 (StyleSheet 규칙보다 우선하도록 직접 지정)
	--   활성  : 배경 accent  · 아이콘 text
	--   비활성: 배경 button(원래 배경색) · 아이콘 inputText
	local function applyVisual()
		box.BackgroundColor3 = if value then Theme.color.accent else Theme.color.button
		checkIcon.ImageColor3 = if value then Theme.color.text else Theme.color.inputText
	end
	applyVisual() -- 초기 상태 반영

	local function setValue(v: boolean)
		value = v
		applyVisual()
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
