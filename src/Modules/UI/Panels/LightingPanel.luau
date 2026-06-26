--!strict
-- 라이팅 세팅 패널. ⚠️ DB(LightingDB) 구조 미완성으로 데이터는 연결하지 않음 — UI 골격만.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Components = script.Parent.Parent.Components
local Label = require(Components.Label)
local Slider = require(Components.Slider)
local Button = require(Components.Button)

local LightingPanel = {}

function LightingPanel.new(): Frame
	local layout = DI.UIListLayout({ Padding = UDim.new(0, 6) })
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = Enum.FillDirection.Vertical

	local panel = DI.Frame({
		Name = "LightingPanel",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		layout,
		Label.new({ Text = "라이팅 세팅", LayoutOrder = 1 }),
		Label.new({ Text = "(DB 미연결 — UI 골격만)", LayoutOrder = 2 }),
		Button.new({ Text = "프리셋: Default ▼", LayoutOrder = 3, OnClick = function() end }),
		Slider.new({ Label = "Brightness", Default = 0.5, LayoutOrder = 4 }).Root,
		Slider.new({ Label = "ClockTime", Default = 0.6, LayoutOrder = 5 }).Root,
		Slider.new({ Label = "ShadowSoftness", Default = 0.2, LayoutOrder = 6 }).Root,
		Button.new({ Text = "적용", LayoutOrder = 7, OnClick = function() end }),
	})

	return panel
end

return LightingPanel
