--[[
	CameraAnimationPlayer — 카메라 리그에 카메라 애니메이션을 재생하고
	플레이어 카메라를 리그 안 "camera" 파트에 고정시키는 트랙.
	Cutscene의 하위 모듈. 공통 Track 인터페이스 구현.

	주의: 카메라 애니메이션이 끝나도 스스로 원상복구하지 않음.
	원상복구는 Cutscene이 Duration 시점에 :Cancel()을 호출할 때만 수행됨.
]]
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local CameraAnimationPlayer = {}
CameraAnimationPlayer.__index = CameraAnimationPlayer

local LOAD_TIMEOUT = 10  -- 초
local idCounter = 0      -- RenderStep 고유 이름용

function CameraAnimationPlayer.new()
	idCounter += 1
	return setmetatable({
		Id = idCounter,
		RenderName = "CutsceneCam_" .. idCounter,
		IsPlaying = false,
		IsPaused = false,
		RigClone = nil,
		CameraPart = nil,
		Track = nil,
		PausedSpeed = nil,
	}, CameraAnimationPlayer)
end

-- 생성 시: 리그 클론 + LoadAnimation + track.Length>0 대기
function CameraAnimationPlayer:Prepare(displayFolder, cameraRigFolder, cameraAnimation)
	self.RigClone = cameraRigFolder:Clone()
	self.RigClone.Parent = displayFolder
	self.RigModel = self.RigClone:IsA("Model") and self.RigClone or self.RigClone:FindFirstChildWhichIsA("Model")
	self.CameraPart = self.RigClone:FindFirstChild("camera", true)

	local controller = self.RigClone:FindFirstChildWhichIsA("AnimationController", true)
		or self.RigClone:FindFirstChildWhichIsA("Humanoid", true)
	if not controller then
		warn("[CameraAnimationPlayer] AnimationController\xea\xb0\x80 \xec\x97\x86\xec\x9d\x8c: " .. cameraRigFolder:GetFullName())
		return
	end

	local animator = controller:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = controller
	end

	self.Track = animator:LoadAnimation(cameraAnimation)
	self.Track.Looped = false

	local t0 = os.clock()
	while self.Track.Length <= 0 and os.clock() - t0 < LOAD_TIMEOUT do
		task.wait()
	end
end

function CameraAnimationPlayer:GetDuration()
	return self.Track and self.Track.Length or 0
end

function CameraAnimationPlayer:GetRig()
	return self.RigModel
end

function CameraAnimationPlayer:Play(startTime)
	if self.IsPlaying then return end
	if not RunService:IsClient() then return end  -- 카메라는 로컬에서만 의미
	if not self.Track or not self.CameraPart then return end
	self.IsPlaying = true
	self.IsPaused = false

	local cam = workspace.CurrentCamera
	self.Camera = cam
	self.SavedCFrame = cam.CFrame
	self.SavedCameraType = cam.CameraType

	local char = Players.LocalPlayer and Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		self.Humanoid = hum
		self.SavedAutoRotate = hum.AutoRotate
		hum.AutoRotate = false
	end

	cam.CameraType = Enum.CameraType.Scriptable

	RunService:BindToRenderStep(self.RenderName, Enum.RenderPriority.Camera.Value, function()
		if self.CameraPart then
			cam.CFrame = self.CameraPart.CFrame
		end
	end)

	self.Track:Play(0)
	if startTime and startTime > 0 then
		self.Track.TimePosition = startTime
	end
end

function CameraAnimationPlayer:Pause()
	if not self.IsPlaying or self.IsPaused then return end
	self.IsPaused = true
	if self.Track then
		self.PausedSpeed = self.Track.Speed
		self.Track:AdjustSpeed(0)
	end
end

function CameraAnimationPlayer:Resume()
	if not self.IsPlaying or not self.IsPaused then return end
	self.IsPaused = false
	if self.Track then
		self.Track:AdjustSpeed(self.PausedSpeed or 1)
		self.PausedSpeed = nil
	end
end

function CameraAnimationPlayer:Seek(t)
	if self.Track then
		self.Track.TimePosition = math.clamp(t, 0, self.Track.Length)
	end
end

-- 정지 + 카메라 원상복구 (Cutscene이 Duration/Cancel 시점에서만 호출)
function CameraAnimationPlayer:Cancel()
	if not self.IsPlaying then return end
	self.IsPlaying = false
	self.IsPaused = false

	pcall(function()
		RunService:UnbindFromRenderStep(self.RenderName)
	end)

	if self.Track then
		self.Track:Stop()
	end

	if self.Humanoid then
		self.Humanoid.AutoRotate = self.SavedAutoRotate
		self.Humanoid = nil
	end

	local cam = self.Camera or workspace.CurrentCamera
	if cam then
		cam.CameraType = self.SavedCameraType or Enum.CameraType.Custom
		if self.SavedCFrame then
			cam.CFrame = self.SavedCFrame
		end
	end
end

function CameraAnimationPlayer:Destroy()
	self:Cancel()
	if self.RigClone then
		self.RigClone:Destroy()
		self.RigClone = nil
	end
	self.Track = nil
	self.CameraPart = nil
end

return CameraAnimationPlayer
