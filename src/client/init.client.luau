--!strict
-- UIController (클라이언트 진입점)
-- UI 라이브러리(ReplicatedStorage.Modules.UI)를 require하여 테스트 UI를 조립·마운트한다.
--   - 라이팅 / Aura / 컷신 창 (드래그 이동, 우하단 리사이즈, x 닫기)
--   - 상단 글로벌 바: 각 창 토글 + "모두 숨기기"
-- 상태는 Observable로 두고 Observer:bindToObservable로 UI에 반영한다. (DB 데이터 미연결)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Artworks = require(ReplicatedStorage.Modules.Artworks)
local Observer = Artworks.Observer

local UI = require(ReplicatedStorage.Modules.UI)
local Window = UI.Components.Window
local Button = UI.Components.Button

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- 루트 ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VFX_TestUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- 스타일시트 연결
UI.Styles.applyTo(screenGui)

-- 상태
local state = UI.State.new()

-- 창들을 담는 컨테이너 (masterHidden으로 일괄 토글, 개별 창 상태는 보존)
local windowsContainer = Instance.new("Frame")
windowsContainer.Name = "Windows"
windowsContainer.Size = UDim2.fromScale(1, 1)
windowsContainer.BackgroundTransparency = 1
windowsContainer.Active = false
windowsContainer.Parent = screenGui

-- 창 정의: 상태 키 / 제목 / 위치 / 패널
local windowDefs = {
	{ key = "lightingVisible", title = "라이팅 세팅", position = UDim2.fromOffset(40, 80), panel = UI.Panels.Lighting },
	{ key = "auraVisible", title = "Aura 테스트", position = UDim2.fromOffset(360, 80), panel = UI.Panels.Aura },
	{ key = "cutsceneVisible", title = "컷신 테스트", position = UDim2.fromOffset(680, 80), panel = UI.Panels.Cutscene },
}

for _, def in windowDefs do
	local window = Window.new({
		Title = def.title,
		Position = def.position,
		Size = UDim2.fromOffset(300, 240),
		MinSize = Vector2.new(220, 160),
		OnClose = function()
			state[def.key] = false
		end,
	})
	window.Root.Parent = windowsContainer

	local content = def.panel.new()
	content.Parent = window.Content

	-- 상태 → 창 표시 여부
	Observer:bindToObservable(state, def.key, function(visible)
		window.Root.Visible = visible
	end)
end

-- masterHidden → 창 컨테이너 표시 여부
Observer:bindToObservable(state, "masterHidden", function(hidden)
	windowsContainer.Visible = not hidden
end)

-- 상단 글로벌 바 (항상 표시 — 모두 숨겨도 이걸로 다시 켤 수 있음)
local barLayout = Instance.new("UIListLayout")
barLayout.FillDirection = Enum.FillDirection.Horizontal
barLayout.SortOrder = Enum.SortOrder.LayoutOrder
barLayout.Padding = UDim.new(0, 6)
barLayout.VerticalAlignment = Enum.VerticalAlignment.Center
barLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.Position = UDim2.fromOffset(0, 0)
topBar:AddTag("TopBar")
topBar.Parent = screenGui

barLayout.Parent = topBar

local barPadding = Instance.new("UIPadding")
barPadding.PaddingLeft = UDim.new(0, 8)
barPadding.PaddingTop = UDim.new(0, 4)
barPadding.PaddingBottom = UDim.new(0, 4)
barPadding.Parent = topBar

local function toggleButton(text: string, order: number, stateKey: string)
	local button = Button.new({
		Text = text,
		Size = UDim2.fromOffset(96, 28),
		LayoutOrder = order,
		OnClick = function()
			state[stateKey] = not state[stateKey]
		end,
	})
	button.Parent = topBar
end

toggleButton("라이팅 세팅", 1, "lightingVisible")
toggleButton("Aura 테스트", 2, "auraVisible")
toggleButton("컷신 테스트", 3, "cutsceneVisible")

-- 모두 숨기기 토글 (텍스트가 상태에 따라 바뀜)
local hideButton = Button.new({
	Text = "모두 숨기기",
	Size = UDim2.fromOffset(110, 28),
	LayoutOrder = 99,
	OnClick = function()
		state.masterHidden = not state.masterHidden
	end,
})
hideButton.Parent = topBar

Observer:bindToObservable(state, "masterHidden", function(hidden)
	hideButton.Text = hidden and "모두 보이기" or "모두 숨기기"
end)

print("[VFX_TestUI] UI 로드 완료")
