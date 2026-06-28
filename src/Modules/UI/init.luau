--!strict
-- UI 라이브러리 진입점. ReplicatedStorage.Modules.UI 로 require하여 사용한다.
-- (혼자 실행되지 않는 ModuleScript 묶음 — 실제 마운트는 client/init.client.luau에서 수행)

local UI = {}

UI.Styles = require(script.Styles.StyleSheet)
UI.Icons = require(script.Styles.Icons)
UI.State = require(script.State)

UI.Components = {
	Window = require(script.Components.Window),
	ScrollPanel = require(script.Components.ScrollPanel),
	Button = require(script.Components.Button),
	Label = require(script.Components.Label),
	Divider = require(script.Components.Divider),
	-- 필드 = 라벨 + 입력 슬롯(Field). 입력은 독립 컴포넌트(XxxInput).
	-- 사용: Field.new({ Label = "X", Input = NumberInput.new({...}) })
	Field = require(script.Components.Field),
	StringInput = require(script.Components.StringInput),
	NumberInput = require(script.Components.NumberInput),
	BooleanInput = require(script.Components.BooleanInput),
	ColorInput = require(script.Components.ColorInput),
	EnumInput = require(script.Components.EnumInput),
	SliderInput = require(script.Components.SliderInput),
}

UI.Panels = {
	Lighting = require(script.Panels.LightingPanel),
	Aura = require(script.Panels.AuraPanel),
	Cutscene = require(script.Panels.CutscenePanel),
	ComponentTest = require(script.Panels.ComponentTestPanel),
}

return UI
