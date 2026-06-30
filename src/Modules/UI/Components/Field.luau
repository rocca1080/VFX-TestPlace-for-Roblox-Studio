--!strict
-- 필드 행 컴포넌트 = 이름 라벨 + 입력 슬롯.
--   한 줄에 라벨(좌) + 입력(우)을 가로 UIListLayout(HorizontalFlex.Fill)로 배치한다.
--   - Field는 "레이아웃"만 담당. 입력의 폭 거동(반반 vs RelativeYY 정사각형)은 입력 자신이 정함.
--   - 값 API(GetValue/SetValue)는 입력 것으로 "포워딩"한다 → field.GetValue()/field.SetValue() 가능.
-- 사용: Field.new({ Label = "Brightness", Input = NumberInput.new({...}) })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme

-- 입력 컴포넌트 공통 형태 (XxxInput.new가 반환)
export type Input<T> = {
	Root: GuiObject,
	GetValue: () -> T,
	SetValue: (value: T) -> (),
}

export type FieldProps = {
	Label: string?,
	Input: Input<any>,
	LayoutOrder: number?,
}

export type Field = {
	Root: Frame,
	GetValue: () -> any,
	SetValue: (value: any) -> (),
}

local ROW_HEIGHT = 26

local Field = {}

function Field.new(props: FieldProps): Field
	local input = props.Input

	local nameLabel = DI.TextLabel({
		Name = "Name",
		Text = props.Label or "",
		Size = UDim2.fromScale(1, 1),
		LayoutOrder = 1,
		"LabelText",
		"FieldLabel", -- 칸 넘치면 … 말줄임
	})
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left

	input.Root.LayoutOrder = 2

	local root = DI.Frame({
		Name = "Field",
		Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder or 0,
		DI.UIListLayout({
			Padding = Theme.dim.gap,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		nameLabel,
		input.Root,
	})

	return {
		Root = root,
		GetValue = input.GetValue,
		SetValue = input.SetValue,
	}
end

return Field
