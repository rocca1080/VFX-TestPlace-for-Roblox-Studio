--!strict
-- 라이팅 세팅 패널. ⚠️ DB(LightingDB) 구조 미완성으로 데이터는 연결하지 않음 — UI 골격만.
-- 스크롤은 ScrollPanel 베이스가, 슬라이더는 Field + SliderInput 조합이 담당한다.

local Components = script.Parent.Parent.Components
local ScrollPanel = require(Components.ScrollPanel)
local Label = require(Components.Label)
local Button = require(Components.Button)
local Field = require(Components.Field)
local SliderInput = require(Components.SliderInput)

local LightingPanel = {}

function LightingPanel.new(): ScrollingFrame
	return ScrollPanel.new({
		Label.new({ Text = "Lighting", LayoutOrder = 1 }),
		Label.new({ Text = "(DB not connected — UI skeleton only)", LayoutOrder = 2 }),
		Button.new({ Text = "Preset: Default ▼", LayoutOrder = 3, OnClick = function() end }),
		Field.new({ Label = "Brightness", LayoutOrder = 4, Input = SliderInput.new({ Default = 0.5 }) }).Root,
		Field.new({ Label = "ClockTime", LayoutOrder = 5, Input = SliderInput.new({ Default = 0.6 }) }).Root,
		Field.new({ Label = "ShadowSoftness", LayoutOrder = 6, Input = SliderInput.new({ Default = 0.2 }) }).Root,
		Button.new({ Text = "Apply", LayoutOrder = 7, OnClick = function() end }),
	})
end

return LightingPanel
