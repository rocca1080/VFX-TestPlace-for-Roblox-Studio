--!strict
-- 라이팅 세팅 패널 (테스트용). 드롭다운/토글 변경 시 실시간 적용 (적용 버튼 없음).
--   - 프리셋: 드롭다운 변경 → LightingManager.Apply(key)
--   - 스카이: 드롭다운 변경 → LightingManager.ApplySky(name)
--   - 구름: 체크박스 토글 → LightingManager.SetCloudsEnabled(on)
--   순서는 ScrollPanel이 배열 순서대로 LayoutOrder를 자동 부여한다(수동 지정 불필요).
--   ⚠️ 임시 구현 — 추후 전체 재작성 예정.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LightingManager = require(ReplicatedStorage.Modules.LightingManager)

local Components = script.Parent.Parent.Components
local ScrollPanel = require(Components.ScrollPanel)
local Label = require(Components.Label)
local Field = require(Components.Field)
local EnumInput = require(Components.EnumInput)
local BooleanInput = require(Components.BooleanInput)
local Divider = require(Components.Divider)

local LightingPanel = {}

function LightingPanel.new(): ScrollingFrame
	local presets = LightingManager.GetPresetNames()
	local skies = LightingManager.GetSkyNames()

	-- 보이는 기본값(presets[1])을 실제 상태와 맞추기 위해 패널 생성 시 1회 적용.
	-- (OnChanged는 "변경 시"만 발동하므로 초기값은 직접 적용해줘야 함)
	LightingManager.Apply(presets[1])

	local presetField = Field.new({
		Label = "Preset",
		Input = EnumInput.new({
			Options = presets,
			Default = presets[1],
			OnChanged = function(key)
				LightingManager.Apply(key)
			end,
		}),
	})

	local skyField = Field.new({
		Label = "Sky",
		Input = EnumInput.new({
			Options = skies,
			Default = skies[1],
			OnChanged = function(name)
				LightingManager.ApplySky(name)
			end,
		}),
	})

	local cloudsField = Field.new({
		Label = "Clouds",
		Input = BooleanInput.new({
			Default = LightingManager.GetCloudsEnabled() or false,
			OnChanged = function(on)
				LightingManager.SetCloudsEnabled(on)
			end,
		}),
	})

	return ScrollPanel.new({
		Label.new({ Text = "Lighting" }),
		Divider.new(),
		presetField.Root,
		Divider.new(),
		skyField.Root,
		Divider.new(),
		cloudsField.Root,
	})
end

return LightingPanel
