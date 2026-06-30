--!strict
-- 컷신 테스트 패널. ⚠️ DB 구조 미완성으로 데이터는 연결하지 않음 — UI 골격만.
-- 스크롤은 ScrollPanel 베이스가 담당한다.

local Components = script.Parent.Parent.Components
local ScrollPanel = require(Components.ScrollPanel)
local Label = require(Components.Label)
local Button = require(Components.Button)

local CutscenePanel = {}

function CutscenePanel.new(): ScrollingFrame
	return ScrollPanel.new({
		Label.new({ Text = "Cutscene Test" }),
		Label.new({ Text = "(DB not connected — UI skeleton only)" }),
		Button.new({ Text = "Select Cutscene ▼", OnClick = function() end }),
		Button.new({ Text = "Play", OnClick = function() end }),
		Button.new({ Text = "Stop", OnClick = function() end }),
	})
end

return CutscenePanel
