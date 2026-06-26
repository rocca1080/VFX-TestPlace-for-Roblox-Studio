--!strict
-- 공용 텍스트 라벨.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

export type LabelProps = {
	Text: string?,
	Size: UDim2?,
	LayoutOrder: number?,
}

local Label = {}

function Label.new(props: LabelProps): TextLabel
	local label = DI.TextLabel({
		Name = "Label",
		Text = props.Text or "",
		Size = props.Size or UDim2.new(1, 0, 0, 20),
		TextWrapped = true,
		LayoutOrder = props.LayoutOrder or 0,
		"LabelText",
	})
	label.TextXAlignment = Enum.TextXAlignment.Left

	return label
end

return Label
