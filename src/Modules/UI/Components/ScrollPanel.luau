--!strict
-- 스크롤 가능한 패널 컨테이너. 모든 패널의 베이스로 사용한다.
-- 구조: ScrollingFrame > UIListLayout + UIPadding + (항목들을 "직접 자식"으로)
--
-- ⚠️ 중간 래퍼 프레임을 두지 않는 게 핵심이다.
--   scale 폭({1,0}) 자식 + AutomaticCanvasSize는 순환참조(캔버스←자식←캔버스) 회피 때문에
--   자식이 캔버스가 아닌 프레임 AbsoluteSize 기준으로 잡혀 패딩/스크롤바 inset을 무시하고
--   삐져나간다. UIListLayout을 ScrollingFrame에 직접 두면(=래퍼 제거) 이 문제가 없다.
--   (Roblox 권장 스크롤 리스트 패턴)
--
-- VerticalScrollBarInset.ScrollBar: 스크롤바가 뜰 때 그 두께만큼 자리를 확보해 UI를 안 가린다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme

local ScrollPanel = {}

-- children: 패널에 넣을 행(GuiObject)들. 각 행의 LayoutOrder로 정렬된다.
function ScrollPanel.new(children: { GuiObject }?): ScrollingFrame
	local scrollbarThickness = Theme.dim.scrollbarThickness

	local layout = DI.UIListLayout({ Padding = UDim.new(0, Theme.dim.gap) })
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = Enum.FillDirection.Vertical

	local panel = DI.ScrollingFrame({
		Name = "ScrollPanel",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = scrollbarThickness,
		ScrollBarImageColor3 = Theme.color.knob,
		layout,
		DI.UIPadding({
			PaddingLeft = UDim.new(0, Theme.dim.gap),
			PaddingRight = UDim.new(0, Theme.dim.gap),
			PaddingTop = UDim.new(0, Theme.dim.gap),
			PaddingBottom = UDim.new(0, Theme.dim.gap),
		}),
	})
	panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
	panel.ScrollingDirection = Enum.ScrollingDirection.Y
	panel.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

	if children then
		for _, child in children do
			child.Parent = panel
		end
	end

	return panel
end

return ScrollPanel
