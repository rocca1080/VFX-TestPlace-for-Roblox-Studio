--[[
	Vignette
	컷신용 비네트 효과 모듈.

	- Vignette.new(player) 로 비네트 개체를 생성하면, 모듈 안에 있는
	  ScreenGui 템플릿을 복제해 전달받은 플레이어의 PlayerGui에 넣는다.
	- BlurRadius / Spread / Color 는 4방향(Left/Right/Top/Bottom) UIShadow에,
	  Transparency 는 CanvasGroup.GroupTransparency 에 Tween으로 적용한다.
	- Tween은 중복으로 재생되지 않는다. :Tween() 호출 시 현재 재생 중인
	  Tween을 모두 중단한 뒤 새 Tween을 재생한다.
	- :Destroy() 로 개체(및 GUI)를 제거한다.

	사용 예시:
		local Vignette = require(...CinematicController.Vignette)
		local v = Vignette.new(player)
		v:Tween({ Transparency = 0.2, BlurRadius = UDim.new(0.3, 0) }, TweenInfo.new(0.5))
		-- ...
		v:Destroy()
]]

local TweenService = game:GetService("TweenService")

local Vignette = {}
Vignette.__index = Vignette

-- 모듈 안에 들어 있는 ScreenGui 템플릿
local TEMPLATE: ScreenGui = script:WaitForChild("Vignette")

-- UIShadow가 들어 있는 4방향 Frame 이름
local SIDES = { "Left", "Right", "Top", "Bottom" }

local DEFAULT_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- 전달받은 플레이어의 PlayerGui를 안전하게 가져온다
local function getPlayerGui(player: Player): PlayerGui
	return player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui") :: PlayerGui
end

function Vignette.new(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Vignette.new: player(Player)가 필요합니다")

	local self = setmetatable({}, Vignette)

	-- 템플릿 복제 후 플레이어에게 부여
	local gui = TEMPLATE:Clone()
	gui.ResetOnSpawn = false
	gui.Parent = getPlayerGui(player)

	self.Player = player
	self.Gui = gui

	-- CanvasGroup(Transparency는 여기 GroupTransparency로 제어) + 4방향 UIShadow 수집
	self.CanvasGroup = gui:WaitForChild("CanvasGroup")
	self.Shadows = {} :: { UIShadow }
	local frame = self.CanvasGroup
	for _, sideName in SIDES do
		local side = frame:FindFirstChild(sideName)
		local shadow = side and side:FindFirstChildWhichIsA("UIShadow")
		if shadow then
			table.insert(self.Shadows, shadow)
		end
	end

	-- 현재 재생 중인 Tween들
	self._tweens = {} :: { Tween }

	return self
end

-- 현재 재생 중인 Tween을 모두 중단한다
function Vignette:StopTween()
	for _, tween in self._tweens do
		tween:Cancel()
	end
	table.clear(self._tweens)
end

--[[
	비네트 속성을 Tween으로 조절한다.
	properties: { BlurRadius = UDim, Spread = UDim2, Color = Color3, Transparency = number, ... }
	  - Transparency 는 CanvasGroup.GroupTransparency 로 적용된다.
	  - 그 외(BlurRadius / Spread / Color)는 4방향 UIShadow에 적용된다.
	tweenInfo:  생략 시 DEFAULT_TWEEN_INFO 사용

	호출 시 현재 재생 중인 Tween을 먼저 중단하므로 중복 재생되지 않는다.
]]
function Vignette:Tween(properties: { [string]: any }, tweenInfo: TweenInfo?)
	assert(self.Gui, "이미 Destroy된 Vignette 개체입니다")

	-- 현재 재생 중인 Tween 중단 후 새로 재생
	
	self:StopTween()

	local info = tweenInfo or DEFAULT_TWEEN_INFO

	-- Transparency 는 CanvasGroup.GroupTransparency 로, 나머지는 UIShadow로 분리
	local shadowProps = {}
	for key, value in properties do
		if key ~= "Transparency" then
			shadowProps[key] = value
		end
	end

	-- Transparency → CanvasGroup.GroupTransparency
	if properties.Transparency ~= nil and self.CanvasGroup then
		local tween = TweenService:Create(self.CanvasGroup, info, { GroupTransparency = properties.Transparency })
		table.insert(self._tweens, tween)
		tween:Play()
	end

	-- BlurRadius / Spread / Color → 4방향 UIShadow
	if next(shadowProps) ~= nil then
		for _, shadow in self.Shadows do
			local tween = TweenService:Create(shadow, info, shadowProps)
			table.insert(self._tweens, tween)
			tween:Play()
		end
	end

	return self
end

-- 비네트 개체와 GUI를 제거한다
function Vignette:Destroy()
	self:StopTween()
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
	self.Shadows = {}
end

return Vignette
