--[[
	FadeInOut — 화면 페이드 인/아웃 효과 모듈.

	- FadeInOut.new(player): ScreenGui + 전체화면 Frame을 생성해 PlayerGui에 부여.
	- :In(duration):  Frame을 화면에 페이드인(나타남, Transparency 1→0) — Tween.
	- :Out(duration): Frame을 페이드아웃(사라짐, Transparency 0→1) — Tween.
	- :SetTransparency(transparency): 즉시 투명도 설정.
	- Tween 재생 시 이미 재생 중인 Tween이 있으면 취소한 뒤 재생한다.
	- :Destroy()

	사용 예시:
		local FadeInOut = require(...CinematicController.FadeInOut)
		local fade = FadeInOut.new(player)
		fade:In(0.5)   -- 0.5초 동안 검게 덮임
		fade:Out(0.5)  -- 0.5초 동안 걸히먴
]]

local TweenService = game:GetService("TweenService")

local FadeInOut = {}
FadeInOut.__index = FadeInOut

local DEFAULT_DURATION = 0.5
local DEFAULT_EASING = Enum.EasingStyle.Quad
local DEFAULT_DIRECTION = Enum.EasingDirection.InOut

local function getPlayerGui(player: Player): PlayerGui
	return player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui") :: PlayerGui
end

function FadeInOut.new(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "FadeInOut.new: player(Player)가 필요합니다")

	local self = setmetatable({}, FadeInOut)

	local gui = Instance.new("ScreenGui")
	gui.Name = "FadeInOut"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 1000
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local frame = Instance.new("Frame")
	frame.Name = "Fade"
	frame.Size = UDim2.fromScale(1, 1)
	frame.Position = UDim2.fromScale(0, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 1  -- 기본은 투명(안 보임)
	frame.Parent = gui

	gui.Parent = getPlayerGui(player)

	self.Player = player
	self.Gui = gui
	self.Frame = frame
	self._tween = nil :: Tween?

	return self
end

-- 현재 재생 중인 Tween을 중단
function FadeInOut:StopTween()
	if self._tween then
		self._tween:Cancel()
		self._tween = nil
	end
end

-- 즉시 투명도 설정(진행 중인 Tween은 취소)
function FadeInOut:SetTransparency(transparency: number)
	assert(self.Frame, "이미 Destroy된 FadeInOut 개체입니다")
	self:StopTween()
	self.Frame.BackgroundTransparency = transparency
	return self
end

-- 화면을 덮으며 나타남 (Transparency → 0)
function FadeInOut:In(duration: number?)
	return self:_fadeTo(0, duration)
end

-- 화면에서 사라짐 (Transparency → 1)
function FadeInOut:Out(duration: number?)
	return self:_fadeTo(1, duration)
end

function FadeInOut:_fadeTo(targetTransparency: number, duration: number?)
	assert(self.Frame, "이미 Destroy된 FadeInOut 개체입니다")

	-- 이미 재생 중인 Tween이 있으면 취소 후 새로 재생
	self:StopTween()

	local info = TweenInfo.new(duration or DEFAULT_DURATION, DEFAULT_EASING, DEFAULT_DIRECTION)
	local tween = TweenService:Create(self.Frame, info, { BackgroundTransparency = targetTransparency })
	self._tween = tween

	tween.Completed:Connect(function()
		if self._tween == tween then
			self._tween = nil
		end
	end)

	tween:Play()
	return self
end

-- 개체와 GUI를 제거
function FadeInOut:Destroy()
	self:StopTween()
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
	self.Frame = nil
end

return FadeInOut
