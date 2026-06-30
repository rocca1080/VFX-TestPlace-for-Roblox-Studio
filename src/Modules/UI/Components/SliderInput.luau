--!strict
-- 슬라이더 입력 컨트롤(라벨 없음). 0~1 값. Field에 끼워서 사용 → 이름 옆 절반을 채움.
--   Root = 트랙(가운데 가로 바) + fill + knob. (Size 1,1 → Field에서 반반)
--   값 수치는 "드래그 중에만" 핸들 위에 툴팁으로 표시한다.
--   툴팁은 ScrollPanel에 잘리지 않도록 ScreenGui 최상위 오버레이로 띄운다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme

export type SliderInputProps = {
	Default: number?,
	OnChanged: ((value: number) -> ())?,
}

export type SliderInput = {
	Root: Frame,
	GetValue: () -> number,
	SetValue: (value: number) -> (),
}

local SliderInput = {}

function SliderInput.new(props: SliderInputProps): SliderInput
	local value = math.clamp(props.Default or 0, 0, 1)

	local fill = DI.Frame({
		Name = "Fill",
		Size = UDim2.fromScale(value, 1),
		"SliderFill",
		DI.UICorner({ CornerRadius = Theme.dim.cornerRound }),
	})

	local knob = DI.Frame({
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(value, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		"SliderKnob",
		DI.UICorner({ CornerRadius = Theme.dim.cornerRound }),
	})

	-- 트랙: (1,1) 슬롯 안에서 세로 가운데 정렬된 가로 바
	local track = DI.TextButton({
		Name = "Track",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 0, 0, 8),
		"SliderTrack",
		DI.UICorner({ CornerRadius = Theme.dim.cornerRound }),
		fill,
		knob,
	})

	local root = DI.Frame({
		Name = "SliderInput",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		track,
	})

	-- ── 드래그 중 핸들 위 툴팁 (ScreenGui 오버레이) ──
	local tooltip: TextLabel? = nil
	local function showTooltip()
		if tooltip then return end
		local screen = root:FindFirstAncestorWhichIsA("ScreenGui")
		if not screen then return end
		local t = DI.TextLabel({
			Name = "SliderTooltip",
			Text = string.format("%.2f", value),
			Size = UDim2.fromOffset(44, 18),
			BackgroundColor3 = Theme.color.button,
			BackgroundTransparency = 0.05,
			ZIndex = 60,
			"LabelText",
			DI.UICorner({ CornerRadius = Theme.dim.corner }),
			DI.UIStroke({ Thickness = 1, Color = Theme.color.outlineColor1 }),
		})
		t.TextXAlignment = Enum.TextXAlignment.Center
		t.Parent = screen
		tooltip = t
	end
	local function moveTooltip()
		if not tooltip then return end
		tooltip.Text = string.format("%.2f", value)
		-- 툴팁은 ScreenGui(IgnoreGuiInset) 오버레이라 GuiInset만큼 보정해야 핸들 바로 위에 맞는다.
		local inset = GuiService:GetGuiInset()
		local kp = knob.AbsolutePosition
		local ks = knob.AbsoluteSize
		local centerX = kp.X + ks.X / 2
		tooltip.Position = UDim2.fromOffset(centerX - 22 + inset.X, kp.Y - 22 + inset.Y) -- 핸들 바로 위
	end
	local function hideTooltip()
		if tooltip then
			tooltip:Destroy()
			tooltip = nil
		end
	end

	local function setValue(v: number)
		value = math.clamp(v, 0, 1)
		fill.Size = UDim2.fromScale(value, 1)
		knob.Position = UDim2.new(value, 0, 0.5, 0)
		if props.OnChanged then props.OnChanged(value) end
	end

	-- 트랙 드래그 입력 처리
	local dragging = false
	local moveConn: RBXScriptConnection?
	local endConn: RBXScriptConnection?

	local function updateFromX(x: number)
		local rel = (x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X)
		setValue(rel)
		moveTooltip()
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		showTooltip()
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
				hideTooltip()
				if moveConn then moveConn:Disconnect() end
				if endConn then endConn:Disconnect() end
			end
		end)
	end)

	root.Destroying:Connect(hideTooltip)

	return {
		Root = root,
		GetValue = function() return value end,
		SetValue = setValue,
	}
end

return SliderInput
