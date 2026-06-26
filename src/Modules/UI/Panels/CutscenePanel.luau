--!strict
-- 컷신 테스트 패널. ⚠️ DB 구조 미완성으로 데이터는 연결하지 않음 — UI 골격만.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Components = script.Parent.Parent.Components
local Label = require(Components.Label)
local Button = require(Components.Button)

local CutscenePanel = {}

function CutscenePanel.new(): Frame
	local layout = DI.UIListLayout({ Padding = UDim.new(0, 6) })
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = Enum.FillDirection.Vertical

	local panel = DI.Frame({
		Name = "CutscenePanel",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		layout,
		Label.new({ Text = "컷신 테스트", LayoutOrder = 1 }),
		Label.new({ Text = "(DB 미연결 — UI 골격만)", LayoutOrder = 2 }),
		Button.new({ Text = "컷신 선택 ▼", LayoutOrder = 3, OnClick = function() end }),
		Button.new({ Text = "재생", LayoutOrder = 4, OnClick = function() end }),
		Button.new({ Text = "정지", LayoutOrder = 5, OnClick = function() end }),
	})

	return panel
end

return CutscenePanel
