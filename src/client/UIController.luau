--!strict
-- UIController
-- UI 라이브러리(ReplicatedStorage.Modules.UI)를 require하여 테스트 UI를 조립·마운트한다.
--   - 라이팅 / Aura / 컷신 창 (드래그 이동, 우하단 리사이즈, x 닫기)
--   - 상단 토글은 TopbarPlus(Icon)로 네이티브 상단바에 배치 (자체 상단바 제거)
-- 상태는 Observable(State)을 단일 소스로 두고 Observer:bindToObservable로 UI/아이콘에 반영한다.
-- (DB 데이터는 미연결)
-- 실제 실행은 client/init.client.luau에서 UIController.start()로 수행한다.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Artworks = require(ReplicatedStorage.Modules.Artworks)
local Observer = Artworks.Observer

-- 창 열기/닫기 애니메이션은 스타일(StyleSheet.States[".Window"].toggle)에 선언되어 있고,
-- 여기서는 창 root의 "Open" attribute만 토글하면 Interactive 바인더가 트윈을 재생한다.

local Icon = require(ReplicatedStorage.Modules.Icon)

local UI = require(ReplicatedStorage.Modules.UI)
local Window = UI.Components.Window

local UIController = {}

local mounted = false

function UIController.start()
	-- 중복 마운트 방지
	if mounted then
		return
	end
	mounted = true

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

	-- 창 정의: 상태 키 / 제목 / 위치 / 패널 / (선택)크기
	local windowDefs = {
		{ key = "lightingVisible", title = "Lighting", position = UDim2.fromOffset(40, 80), panel = UI.Panels.Lighting },
		{ key = "auraVisible", title = "Aura Test", position = UDim2.fromOffset(360, 80), panel = UI.Panels.Aura },
		{ key = "cutsceneVisible", title = "Cutscene Test", position = UDim2.fromOffset(680, 80), panel = UI.Panels.Cutscene },
		{ key = "componentsVisible", title = "Component Test", position = UDim2.fromOffset(1000, 80), size = UDim2.fromOffset(320, 360), panel = UI.Panels.ComponentTest },
	}

	for order, def in windowDefs do
		-- 창 생성
		local window = Window.new({
			Title = def.title,
			Position = def.position,
			Size = def.size or UDim2.fromOffset(300, 240),
			MinSize = Vector2.new(220, 160),
			OnClose = function()
				state[def.key] = false
			end,
		})
		window.Root.Parent = windowsContainer

		local content = def.panel.new()
		content.Parent = window.Content

		-- 상단바 아이콘 (TopbarPlus)
		local icon = Icon.new()
		icon:setLabel(def.title)
		icon:setCaption(def.title)
		icon:setOrder(order)
		icon:setLeft()
		icon:autoDeselect(false) -- 다른 아이콘 선택해도 풀리지 않게 (창 여러 개 동시 표시)
		icon.toggled:Connect(function(isSelected)
			state[def.key] = isSelected
		end)

		-- 상태 → 창 "Open" attribute 토글(애니메이션은 Interactive 바인더가 처리) + 아이콘 동기화
		Observer:bindToObservable(state, def.key, function(visible)
			window.Root:SetAttribute("Open", visible)
			if visible then
				icon:select()
			else
				icon:deselect()
			end
		end)
	end

	-- "모두 숨기기" 아이콘 (창만 숨기고 아이콘은 남겨 다시 켤 수 있게)
	local hideIcon = Icon.new()
	hideIcon:setLabel("Hide All")
	hideIcon:setCaption("Show/Hide all windows")
	hideIcon:setOrder(99)
	hideIcon:setRight()
	hideIcon:autoDeselect(false)
	hideIcon.toggled:Connect(function(isSelected)
		state.masterHidden = isSelected
	end)

	Observer:bindToObservable(state, "masterHidden", function(hidden)
		windowsContainer.Visible = not hidden
		hideIcon:setLabel(hidden and "Show All" or "Hide All")
		if hidden then
			hideIcon:select()
		else
			hideIcon:deselect()
		end
	end)

	print("[VFX_TestUI] UI loaded (Topbar icons linked)")
end

return UIController
