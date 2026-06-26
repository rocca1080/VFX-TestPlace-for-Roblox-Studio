--!strict
-- UI 라이브러리 진입점. ReplicatedStorage.Modules.UI 로 require하여 사용한다.
-- (혼자 실행되지 않는 ModuleScript 묶음 — 실제 마운트는 client/init.client.luau에서 수행)

local UI = {}

UI.Styles = require(script.Styles.StyleSheet)
UI.State = require(script.State)

UI.Components = {
	Window = require(script.Components.Window),
	Button = require(script.Components.Button),
	Slider = require(script.Components.Slider),
	Label = require(script.Components.Label),
}

UI.Panels = {
	Lighting = require(script.Panels.LightingPanel),
	Aura = require(script.Panels.AuraPanel),
	Cutscene = require(script.Panels.CutscenePanel),
}

return UI
