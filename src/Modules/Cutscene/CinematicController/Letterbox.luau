--[[
	Letterbox — 시네마틱 레터박스(상/하 검은 띄) 효과 모듈.

	- Letterbox.new(player): ScreenGui + 위쪽 Frame + 아래쪽 Frame을 생성해 PlayerGui에 부여.
	- 비율(ratio) 0~1: ratio=1이면 각 Frame의 yScale=0.5로 화면을 완전히 가림.
	  (각 Frame yScale = ratio * 0.5)
	- :Set(ratio):           즉시 설정.
	- :Tween(ratio, duration): Tween으로 이동.
	- Tween 재생 시 이미 재생 중인 Tween이 있으면 취소한 뒤 재생한다.
	- :Destroy()

	사용 예시:
		local Letterbox = require(...CinematicController.Letterbox)
		local lb = Letterbox.new(player)
		lb:Tween(1, 0.5)   -- 0.5초 동안 상/하 띄가 화면을 완전히 가림
		lb:Set(0)          -- 즉시 띄 제거
]]

local TweenService = game:GetService("TweenService")

local Letterbox = {}
Letterbox.__index = Letterbox

local DEFAULT_DURATION = 0.5
local DEFAULT_EASING = Enum.EasingStyle.Quad
local DEFAULT_DIRECTION = Enum.EasingDirection.Out

local function getPlayerGui(player: Player): PlayerGui
	return player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui") :: PlayerGui
end

-- 상/하 띄 Frame 생성. anchorY/posY로 위쪽(위→아래)·아래쪽(아래→위) 결정.
local function makeBar(name: string, anchorY: number, posY: number): Frame
	local bar = Instance.new("Frame")
	bar.Name = name
	bar.BackgroundColor3 = Color3.new(0, 0, 0)
	bar.BorderSizePixel = 0
	bar.AnchorPoint = Vector2.new(0, anchorY)
	bar.Position = UDim2.fromScale(0, posY)
	bar.Size = UDim2.fromScale(1, 0)
	return bar
end

-- 비율(0~1) → 각 Frame의 yScale(ratio*0.5)
local function ratioToScale(ratio: number): number
	return math.clamp(ratio, 0, 1) * 0.5
end

function Letterbox.new(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Letterbox.new: player(Player)가 필요합니다")

	local self = setmetatable({}, Letterbox)

	local gui = Instance.new("ScreenGui")
	gui.Name = "Letterbox"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 1000
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local top = makeBar("Top", 0, 0)        -- 위쪽: 위에서 아래로 자람
	top.Parent = gui
	local bottom = makeBar("Bottom", 1, 1)  -- 아래쪽: 아래에서 위로 자람
	bottom.Parent = gui

	gui.Parent = getPlayerGui(player)

	self.Player = player
	self.Gui = gui
	self.Top = top
	self.Bottom = bottom
	self._tweens = {} :: { Tween }

	return self
end

-- 현재 재생 중인 Tween을 모두 중단
function Letterbox:StopTween()
	for _, tween in self._tweens do
		tween:Cancel()
	end
	table.clear(self._tweens)
end

-- 즉시 설정(진행 중인 Tween은 취소)
function Letterbox:Set(ratio: number)
	assert(self.Top, "이미 Destroy된 Letterbox 개체입니다")
	self:StopTween()
	local h = ratioToScale(ratio)
	self.Top.Size = UDim2.fromScale(1, h)
	self.Bottom.Size = UDim2.fromScale(1, h)
	return self
end

-- Tween으로 이동(이미 재생 중인 Tween은 취소 후 재생)
function Letterbox:Tween(ratio: number, duration: number?)
	assert(self.Top, "이미 Destroy된 Letterbox 개체입니다")
	self:StopTween()

	local h = ratioToScale(ratio)
	local info = TweenInfo.new(duration or DEFAULT_DURATION, DEFAULT_EASING, DEFAULT_DIRECTION)
	local target = { Size = UDim2.fromScale(1, h) }

	for _, bar in { self.Top, self.Bottom } do
		local tween = TweenService:Create(bar, info, target)
		table.insert(self._tweens, tween)
		tween:Play()
	end

	return self
end

-- 개체와 GUI를 제거
function Letterbox:Destroy()
	self:StopTween()
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
	self.Top = nil
	self.Bottom = nil
end

return Letterbox
