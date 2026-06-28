--!strict
-- Color3 입력 컨트롤(라벨 없음). Field에 끼워서 사용.
--   레이아웃: [스와치 버튼(정사각형)] + [R][G][B] 숫자 입력(0~255, NumberInput 재활용)
--   - 스와치 클릭 → HSV 컬러피커 Window 팝업 (SV 사각형 + Hue + HEX + R/G/B, 양방향)
--   - RGB 입력 ↔ 스와치/피커 모두 양방향 동기화 (updating 가드로 루프 방지)
-- 반환: { Root, GetValue, SetValue }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Window = require(script.Parent.Window)
local NumberInput = require(script.Parent.NumberInput)
local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme

local ColorInput = {}

local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)

-- 한 번에 하나의 피커만 열리도록 모듈 전역으로 현재 피커 닫기 함수를 보관한다.
local activeClose: (() -> ())? = nil

export type ColorInputProps = {
	Default: Color3?,
	Title: string?,
	OnChanged: ((value: Color3) -> ())?,
}

export type ColorInput = {
	Root: Frame,
	GetValue: () -> Color3,
	SetValue: (value: Color3) -> (),
}

local function toHex(c: Color3): string
	return string.format("%02X%02X%02X", math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255))
end

local function fromHex(text: string): Color3?
	local hex = text:gsub("#", ""):gsub("%s", "")
	if #hex ~= 6 then return nil end
	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)
	if r and g and b then return Color3.fromRGB(r, g, b) end
	return nil
end

local function bindDrag(surface: GuiObject, onUpdate: (x: number, y: number) -> ())
	local dragging = false
	local moveConn: RBXScriptConnection?
	local endConn: RBXScriptConnection?
	surface.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		onUpdate(input.Position.X, input.Position.Y)
		moveConn = UserInputService.InputChanged:Connect(function(moveInput)
			if not dragging then return end
			if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement and moveInput.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			onUpdate(moveInput.Position.X, moveInput.Position.Y)
		end)
		endConn = UserInputService.InputEnded:Connect(function(endInput)
			if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				if moveConn then moveConn:Disconnect() end
				if endConn then endConn:Disconnect() end
			end
		end)
	end)
end

function ColorInput.new(props: ColorInputProps): ColorInput
	local value = props.Default or WHITE
	local h, s, v = value:ToHSV()
	local updating = false
	local refreshOpenPicker: (() -> ())? = nil

	-- 스와치 (정사각형, 클릭 시 피커 열기)
	local swatch = DI.TextButton({
		Name = "Swatch",
		Text = "",
		AutoButtonColor = true,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		LayoutOrder = 1,
		BackgroundColor3 = value,
		"Swatch",
		DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
	})
	-- 스와치는 정사각형 고정(RelativeYY) + flex에서 제외(None) → RGB 입력들만 남은 폭을 나눠 채움
	local swatchFlex = DI.UIFlexItem({})
	swatchFlex.FlexMode = Enum.UIFlexMode.None
	swatchFlex.Parent = swatch

	-- R/G/B 입력 (NumberInput 재활용)
	local onRGB: (() -> ())? = nil
	local function makeRGB(default: number, order: number): NumberInput.NumberInput
		local ni = NumberInput.new({
			Min = 0,
			Max = 255,
			Default = default,
			OnChanged = function() if onRGB then onRGB() end end,
		})
		ni.Root.LayoutOrder = order
		return ni
	end
	local rInput = makeRGB(math.round(value.R * 255), 2)
	local gInput = makeRGB(math.round(value.G * 255), 3)
	local bInput = makeRGB(math.round(value.B * 255), 4)

	local root = DI.Frame({
		Name = "ColorInput",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		DI.UIListLayout({
			Padding = UDim.new(0, Theme.dim.gap),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		swatch,
		rInput.Root,
		gInput.Root,
		bInput.Root,
	})

	-- 모든 출력(스와치 + 필드 RGB + 피커)을 현재 value 기준으로 갱신
	local function updateOutputs()
		swatch.BackgroundColor3 = value
		updating = true
		rInput.SetValue(math.round(value.R * 255))
		gInput.SetValue(math.round(value.G * 255))
		bInput.SetValue(math.round(value.B * 255))
		updating = false
		if refreshOpenPicker then refreshOpenPicker() end
	end

	local function commit()
		updateOutputs()
		if props.OnChanged then props.OnChanged(value) end
	end

	onRGB = function()
		if updating then return end
		value = Color3.fromRGB(rInput.GetValue(), gInput.GetValue(), bInput.GetValue())
		h, s, v = value:ToHSV()
		commit()
	end

	-- ── 피커 열기 ──
	local function open()
		if activeClose then activeClose() end
		local screen = root:FindFirstAncestorWhichIsA("ScreenGui")
		if not screen then return end

		local whiteOverlay = DI.Frame({
			Name = "White", Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, ZIndex = 2,
			DI.UIGradient({ Color = ColorSequence.new(WHITE), Transparency = NumberSequence.new(0, 1), Rotation = 0 }),
		})
		local blackOverlay = DI.Frame({
			Name = "Black", Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK, ZIndex = 3,
			DI.UIGradient({ Color = ColorSequence.new(BLACK), Transparency = NumberSequence.new(1, 0), Rotation = 90 }),
		})
		local svStroke = DI.UIStroke({ Thickness = 2, Color = BLACK })
		local svKnob = DI.Frame({
			Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = value, ZIndex = 6, DI.UICorner({ CornerRadius = UDim.new(1, 0) }), svStroke,
		})
		-- 드래그 입력을 받는 투명 버튼 (오버레이 위, 노브 아래) — 노브는 비활성 Frame이라 입력은 여기로 떨어짐
		local svSurface = DI.TextButton({
			Name = "Surface", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1), ZIndex = 5,
		})
		-- SV 사각형을 CanvasGroup으로 묶고 UICorner를 그룹에 적용 → 오버레이까지 한 번에 둥글게 클립됨
		local svSquare = DI.CanvasGroup({
			Name = "SV", Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Color3.fromHSV(h, 1, 1), LayoutOrder = 1, ZIndex = 1,
			DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
			whiteOverlay, blackOverlay, svSurface, svKnob,
		})
		svSquare.ClipsDescendants = true
		local svFlex = DI.UIFlexItem({})
		svFlex.FlexMode = Enum.UIFlexMode.Fill
		svFlex.Parent = svSquare

		local hueKeys = {}
		for i = 0, 6 do
			table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
		end
		local hueHandle = DI.Frame({
			Name = "Handle", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(h, 0.5),
			Size = UDim2.fromOffset(8, 22), BackgroundColor3 = Color3.fromHSV(h, 1, 1), ZIndex = 2,
			DI.UICorner({ CornerRadius = UDim.new(0, 3) }), DI.UIStroke({ Thickness = 2, Color = BLACK }),
		})
		local hueBar = DI.TextButton({
			Name = "Hue", Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 16),
			BackgroundColor3 = WHITE, LayoutOrder = 2, ZIndex = 1, DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
			DI.UIGradient({ Color = ColorSequence.new(hueKeys), Rotation = 0 }), hueHandle,
		})

		local hexLabel = DI.TextLabel({ Name = "HexLabel", Text = "HEX", Size = UDim2.new(0, 36, 1, 0), "LabelText" })
		hexLabel.TextXAlignment = Enum.TextXAlignment.Left
		local hexInput = DI.TextBox({
			Name = "HexInput", Text = toHex(value), PlaceholderText = "RRGGBB", ClearTextOnFocus = false,
			Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -88, 1, 0), "Input",
			DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
		})
		hexInput.TextXAlignment = Enum.TextXAlignment.Center
		local preview = DI.Frame({
			Name = "Preview", Position = UDim2.new(1, -44, 0, 0), Size = UDim2.new(0, 44, 1, 0),
			BackgroundColor3 = value, "Swatch", DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
		})
		local hexRow = DI.Frame({
			Name = "HexRow", Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 3,
			hexLabel, hexInput, preview,
		})

		local channelNames = { "R", "G", "B" }
		local pickerRgb: { TextBox } = {}
		local rgbChildren: { Instance } = {}
		for i = 1, 3 do
			local chLabel = DI.TextLabel({
				Name = channelNames[i] .. "Label", Text = channelNames[i],
				Position = UDim2.new((i - 1) / 3, 0, 0, 0), Size = UDim2.new(0, 14, 1, 0), "LabelText",
			})
			chLabel.TextXAlignment = Enum.TextXAlignment.Left
			local chInput = DI.TextBox({
				Name = channelNames[i], Text = "0", PlaceholderText = channelNames[i], ClearTextOnFocus = false,
				Position = UDim2.new((i - 1) / 3, 16, 0, 0), Size = UDim2.new(1 / 3, -20, 1, 0), "Input",
				DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
			})
			chInput.TextXAlignment = Enum.TextXAlignment.Center
			pickerRgb[i] = chInput
			table.insert(rgbChildren, chLabel)
			table.insert(rgbChildren, chInput)
		end
		local rgbRow = DI.Frame({
			Name = "RgbRow", Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 4,
		})
		for _, child in rgbChildren do child.Parent = rgbRow end

		local listLayout = DI.UIListLayout({ Padding = UDim.new(0, 6) })
		listLayout.FillDirection = Enum.FillDirection.Vertical
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local content = DI.Frame({
			Name = "ColorPicker", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			DI.UIPadding({
				PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
			}),
			listLayout, svSquare, hueBar, hexRow, rgbRow,
		})

		-- 피커 위젯만 현재 value/h,s,v 기준으로 다시 그린다 (필드 출력/OnChanged는 건드리지 않음)
		local function redrawPicker()
			svSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			svKnob.Position = UDim2.fromScale(s, 1 - v)
			svKnob.BackgroundColor3 = value
			-- 체감 밝기(luminance) 기준: 밝으면(검정 테두리), 어두우면(흰 테두리)
			-- Y = (R*299 + G*587 + B*114) / 1000  (R,G,B는 0~255)
			local luminance = (value.R * 255 * 299 + value.G * 255 * 587 + value.B * 255 * 114) / 1000
			svStroke.Color = if luminance >= 128 then BLACK else WHITE
			hueHandle.Position = UDim2.fromScale(h, 0.5)
			hueHandle.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			preview.BackgroundColor3 = value
			hexInput.Text = toHex(value)
			pickerRgb[1].Text = tostring(math.round(value.R * 255))
			pickerRgb[2].Text = tostring(math.round(value.G * 255))
			pickerRgb[3].Text = tostring(math.round(value.B * 255))
		end

		bindDrag(svSurface, function(x, y)
			s = math.clamp((x - svSurface.AbsolutePosition.X) / math.max(1, svSurface.AbsoluteSize.X), 0, 1)
			v = 1 - math.clamp((y - svSurface.AbsolutePosition.Y) / math.max(1, svSurface.AbsoluteSize.Y), 0, 1)
			value = Color3.fromHSV(h, s, v)
			commit()
		end)
		bindDrag(hueBar, function(x, _)
			h = math.clamp((x - hueBar.AbsolutePosition.X) / math.max(1, hueBar.AbsoluteSize.X), 0, 1)
			value = Color3.fromHSV(h, s, v)
			commit()
		end)
		hexInput.FocusLost:Connect(function()
			local parsed = fromHex(hexInput.Text)
			if parsed then
				value = parsed
				h, s, v = parsed:ToHSV()
				commit()
			else
				hexInput.Text = toHex(value)
			end
		end)
		local function commitPickerRGB()
			local r = math.clamp(tonumber(pickerRgb[1].Text) or math.round(value.R * 255), 0, 255)
			local g = math.clamp(tonumber(pickerRgb[2].Text) or math.round(value.G * 255), 0, 255)
			local b = math.clamp(tonumber(pickerRgb[3].Text) or math.round(value.B * 255), 0, 255)
			value = Color3.fromRGB(r, g, b)
			h, s, v = value:ToHSV()
			commit()
		end
		for i = 1, 3 do
			pickerRgb[i].FocusLost:Connect(commitPickerRGB)
		end

		-- 창 생성
		-- 피커 창은 ScreenGui(IgnoreGuiInset) 직속이라 GuiInset만큼 보정해 스와치 아래에 맞춘다.
		local inset = GuiService:GetGuiInset()
		local PANEL_W, PANEL_H = 260, 300
		local sp = swatch.AbsolutePosition
		local screenSize = screen.AbsoluteSize
		local px = math.clamp(sp.X + inset.X, 4, math.max(4, screenSize.X - PANEL_W - 4))
		local py = math.clamp(sp.Y + swatch.AbsoluteSize.Y + 4 + inset.Y, 4, math.max(4, screenSize.Y - PANEL_H - 4))

		local closed = false
		local pickerWindow: Window.Window? = nil
		local function closePicker()
			if closed then return end
			closed = true
			refreshOpenPicker = nil
			if activeClose == closePicker then activeClose = nil end
			if pickerWindow then pickerWindow.Root:Destroy() end
		end

		pickerWindow = Window.new({
			Title = props.Title or "Color",
			Size = UDim2.fromOffset(PANEL_W, PANEL_H),
			Position = UDim2.fromOffset(px, py),
			MinSize = Vector2.new(240, 280),
			OnClose = closePicker,
		})
		content.Parent = pickerWindow.Content
		pickerWindow.Root.Parent = screen
		pickerWindow.Root:SetAttribute("Open", true)

		refreshOpenPicker = redrawPicker
		activeClose = closePicker
		updateOutputs() -- 필드 + 피커 동기화 (OnChanged은 발생시키지 않음)
	end

	swatch.Activated:Connect(open)

	local function setValue(c: Color3)
		value = c
		h, s, v = c:ToHSV()
		commit()
	end

	return {
		Root = root,
		GetValue = function() return value end,
		SetValue = setValue,
	}
end

return ColorInput
