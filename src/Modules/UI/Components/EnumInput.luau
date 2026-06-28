--!strict
-- Enum/선택 입력 컨트롤(라벨 없음) = 헤더 버튼. Field에 끼워서 사용.
--   헤더 클릭 시 옵션 목록이 "팝업"으로 뜬다 (인라인 확장이 아니라 다른 UI를 밀지 않음).
--   - 팝업은 ScreenGui 최상위에 띄워 창/스크롤에 잘리지 않음
--   - 배경 클릭 시 닫힘, 한 번에 하나만 열림(activeClose)
-- 반환: { Root = 헤더, GetValue, SetValue }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme

export type EnumInputProps = {
	Options: { string }?,
	Default: string?,
	OnChanged: ((value: string) -> ())?,
}

export type EnumInput = {
	Root: TextButton,
	GetValue: () -> string,
	SetValue: (value: string) -> (),
}

local OPTION_HEIGHT = 24

-- 한 번에 하나의 드롭다운만 열리도록 모듈 전역으로 현재 팝업 닫기 함수를 보관한다.
local activeClose: (() -> ())? = nil

local EnumInput = {}

function EnumInput.new(props: EnumInputProps): EnumInput
	local options = props.Options or {}
	local value = props.Default or options[1] or ""

	local header = DI.TextButton({
		Name = "EnumInput",
		Text = "",
		AutoButtonColor = false, -- hover/press는 Interactive 바인더(.Btn States)가 트윈으로 처리
		Size = UDim2.fromScale(1, 1),
		"Btn",
		DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
		DI.UIPadding({
			PaddingLeft = UDim.new(0, Theme.dim.inputPadding),
			PaddingRight = UDim.new(0, Theme.dim.inputPadding),
		}),
	})
	header.TextXAlignment = Enum.TextXAlignment.Left

	local function updateHeader()
		local shown = if value ~= "" then value else "(select)"
		header.Text = shown .. "   ▼"
	end

	local myClose: (() -> ())? = nil

	local function openPopup()
		if activeClose then
			activeClose()
		end

		local screen = header:FindFirstAncestorWhichIsA("ScreenGui")
		if not screen then
			return
		end

		local listFrame = DI.Frame({
			Name = "EnumPopup",
			BackgroundColor3 = Theme.color.background,
			BackgroundTransparency = 0.05,
			Active = true,
			ZIndex = 51,
			DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
			DI.UIStroke({ Thickness = 1, Color = Theme.color.outlineColor1 }),
			DI.UIListLayout({
				Padding = UDim.new(0, 2),
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			DI.UIPadding({
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			}),
		})
		listFrame.AutomaticSize = Enum.AutomaticSize.Y

		-- 팝업은 ScreenGui(IgnoreGuiInset) 직속이라 AbsolutePosition 기준이 GuiInset만큼 어긋난다.
		-- inset을 더해 헤더 "바로 아래"(글로벌 좌표)에 정확히 맞춘다.
		local inset = GuiService:GetGuiInset()
		local hp = header.AbsolutePosition
		local hs = header.AbsoluteSize
		listFrame.Position = UDim2.fromOffset(hp.X + inset.X, hp.Y + hs.Y + 2 + inset.Y)
		listFrame.Size = UDim2.fromOffset(hs.X, 0)

		local backdrop = DI.TextButton({
			Name = "EnumBackdrop",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 50,
			listFrame,
		})

		local function close()
			backdrop:Destroy()
			if activeClose == myClose then
				activeClose = nil
			end
			myClose = nil
		end
		myClose = close

		for i, optionText in options do
			local optionButton = DI.TextButton({
				Name = "Option_" .. tostring(i),
				Text = "  " .. optionText,
				AutoButtonColor = true,
				Size = UDim2.new(1, 0, 0, OPTION_HEIGHT),
				LayoutOrder = i,
				ZIndex = 52,
				"EnumOption",
				DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
			})
			optionButton.TextXAlignment = Enum.TextXAlignment.Left
			optionButton.Activated:Connect(function()
				value = optionText
				updateHeader()
				close()
				if props.OnChanged then props.OnChanged(value) end
			end)
			optionButton.Parent = listFrame
		end

		backdrop.Activated:Connect(close)
		backdrop.Parent = screen
		activeClose = myClose
	end

	header.Activated:Connect(openPopup)

	updateHeader()

	local function setValue(val: string)
		value = val
		updateHeader()
		if props.OnChanged then props.OnChanged(value) end
	end

	return {
		Root = header,
		GetValue = function() return value end,
		SetValue = setValue,
	}
end

return EnumInput
