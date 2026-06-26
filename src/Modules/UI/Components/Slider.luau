--!strict
-- 0~1 값을 가지는 가로 슬라이더. 데이터(DB) 연결 없이 값 변경만 콜백으로 전달한다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

export type SliderProps = {
	Label: string?,
	Default: number?,
	LayoutOrder: number?,
	OnChanged: ((value: number) -> ())?,
}

export type Slider = {
	Root: Frame,
	GetValue: () -> number,
	SetValue: (value: number) -> (),
}

local Slider = {}

function Slider.new(props: SliderProps): Slider
	local value = math.clamp(props.Default or 0, 0, 1)

	local fill = DI.Frame({
		Name = "Fill",
		Size = UDim2.fromScale(value, 1),
		"SliderFill",
		DI.UICorner({ CornerRadius = UDim.new(1, 0) }),
	})

	local knob = DI.Frame({
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(value, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		"SliderKnob",
		DI.UICorner({ CornerRadius = UDim.new(1, 0) }),
	})

	local track = DI.TextButton({
		Name = "Track",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 1, -14),
		"SliderTrack",
		DI.UICorner({ CornerRadius = UDim.new(1, 0) }),
		fill,
		knob,
	})

	local nameLabel = DI.TextLabel({
		Name = "Name",
		Text = props.Label or "Value",
		Size = UDim2.new(0.7, 0, 0, 18),
		"LabelText",
	})
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left

	local valueLabel = DI.TextLabel({
		Name = "ValueText",
		Text = string.format("%.2f", value),
		Size = UDim2.new(0.3, 0, 0, 18),
		Position = UDim2.new(0.7, 0, 0, 0),
		"LabelText",
	})
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local root = DI.Frame({
		Name = "Slider",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder or 0,
		nameLabel,
		valueLabel,
		track,
	})

	local function setValue(v: number)
		value = math.clamp(v, 0, 1)
		fill.Size = UDim2.fromScale(value, 1)
		knob.Position = UDim2.new(value, 0, 0.5, 0)
		valueLabel.Text = string.format("%.2f", value)
		if props.OnChanged then props.OnChanged(value) end
	end

	-- 트랙 드래그 입력 처리
	local dragging = false
	local moveConn: RBXScriptConnection?
	local endConn: RBXScriptConnection?

	local function updateFromX(x: number)
		local rel = (x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X)
		setValue(rel)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		updateFromX(input.Position.X)

		moveConn = UserInputService.InputChanged:Connect(function(moveInput)
			if not dragging then return end
			if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement and moveInput.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			updateFromX(moveInput.Position.X)
		end)

		endConn = UserInputService.InputEnded:Connect(function(endInput)
			if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				if moveConn then moveConn:Disconnect() end
				if endConn then endConn:Disconnect() end
			end
		end)
	end)

	return {
		Root = root,
		GetValue = function() return value end,
		SetValue = setValue,
	}
end

return Slider
