--!strict
-- Aura 테스트 패널. ⚠️ DB(AuraDB) 구조 미완성으로 데이터는 연결하지 않음 — UI 골격만.
-- 스크롤은 ScrollPanel 베이스가 담당한다.

local Components = script.Parent.Parent.Components
local ScrollPanel = require(Components.ScrollPanel)
local Label = require(Components.Label)
local Button = require(Components.Button)

local AuraPanel = {}

function AuraPanel.new(): ScrollingFrame
	return ScrollPanel.new({
		Label.new({ Text = "Aura Test" }),
		Label.new({ Text = "(DB not connected — UI skeleton only)" }),
		Button.new({ Text = "Select Aura ▼", OnClick = function() end }),
		Button.new({ Text = "Spawn", OnClick = function() end }),
		Button.new({ Text = "Remove", OnClick = function() end }),
	})
end

return AuraPanel
