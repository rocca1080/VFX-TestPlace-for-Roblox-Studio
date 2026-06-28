--!strict
-- 공용 텍스트 버튼.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

export type ButtonProps = {
	Text: string?,
	Size: UDim2?,
	LayoutOrder: number?,
	OnClick: (() -> ())?,
}

local Button = {}

function Button.new(props: ButtonProps): TextButton
	local button = DI.TextButton({
		Name = "Button",
		Text = props.Text or "Button",
		Size = props.Size or UDim2.new(1, 0, 0, 28),
		AutoButtonColor = false, -- hover/press는 Interactive 바인더(.Btn States)가 트윈으로 처리

		LayoutOrder = props.LayoutOrder or 0,
		"Btn",
		DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
		Activated = function()
			if props.OnClick then props.OnClick() end
		end,
	})

	return button
end

return Button
