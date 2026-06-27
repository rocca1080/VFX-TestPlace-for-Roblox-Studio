--[[
	Cutscene — 캐릭터 애니메이션 + 카메라 애니메이션을 하나의 타임라인 단위로 재생하는 모듈.

	컷신 폴더 계약:
		Characters/           -- 캐릭터 Model들 (필수)
		CharactersAnimation/  -- Animation들 (이름 = Characters 모델 이름)
		CameraAnimation/      -- 카메라 Animation (선택)
		CameraRig/            -- 카메라 리그 폴더: AnimationController + "camera" 파트 (선택)

	CameraRig/CameraAnimation이 없으면 캐릭터 애니메이션만 재생합니다.

	API:
		Cutscene.new(cutsceneFolder, opts) -> cutscene   -- 생성 즉시 로드 시작
			opts = { length?, parent?, autoFinish?, origin? }
		cutscene.Loaded     : Signal      -- 로드 완료 시 1회 발생(기억형)
		cutscene.Finished   : Signal      -- 재생 종료/취소 시 발생
		cutscene:GetCharacters() -> { [name] = clone }
		cutscene:GetCameraRig()  -> Model?  -- 클론된 카메라 리그(없으면 nil)
		cutscene:GetDuration()   -> number
		cutscene:Play(startTime?)            -- origin(생성 시 지정)은 로드 후 1회 적용됨
		cutscene:Pause() / :Resume() / :Cancel()
		cutscene:Seek(t)
		cutscene:Destroy()
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterAnimator = require(script:WaitForChild("CharacterAnimator"))
local CameraAnimationPlayer = require(script:WaitForChild("CameraAnimationPlayer"))
local Signal = require(script:WaitForChild("Signal"))

local Cutscene = {}
Cutscene.__index = Cutscene

-- 로딩/보관 중 클론을 DataModel 안에 두기 위한 숨은 홀더(workspace 밖이라 렌더되지 않음).
-- AnimationTrack.Length는 리그가 DataModel 안에 있어야 채워지므로, parent=nil 대신 여기에 보관한다.
local function getHoldingParent()
	local holder = ReplicatedStorage:FindFirstChild("_CutsceneHolding")
	if not holder then
		holder = Instance.new("Folder")
		holder.Name = "_CutsceneHolding"
		holder.Parent = ReplicatedStorage
	end
	return holder
end

function Cutscene.new(cutsceneFolder, opts)
	opts = opts or {}
	local self = setmetatable({}, Cutscene)

	self.Folder = cutsceneFolder
	self.Name = cutsceneFolder.Name
	self.Length = opts.length            -- 명시적 컷신 길이(없으면 트랙 최대 길이)
	self.TargetParent = opts.parent      -- 표시 대상 부모(없으면 Play 시 결정)
	self.AutoFinish = opts.autoFinish ~= false  -- 기본 true
	self.Origin = opts.origin                    -- 생성 시 지정하면 로드 직후 origin 기준으로 1회 배치

	self.Loaded = Signal.new(true)       -- latching(기억형)
	self.Finished = Signal.new(false)

	self.IsLoaded = false
	self.IsPlaying = false
	self.IsPaused = false
	self.Duration = self.Length or 0

	-- 모든 클론을 담는 display 폴더(컷신 폴더명과 동일).
	-- 평소엔 숨은 홀더(DataModel 안)에 보관 → 애니메이션 Length가 정상 로드됨.
	self.HoldingParent = getHoldingParent()
	self.Display = Instance.new("Folder")
	self.Display.Name = cutsceneFolder.Name
	self.Display.Parent = self.HoldingParent

	-- 하위 폴더 해석
	local charactersFolder = cutsceneFolder:FindFirstChild("Characters")
	local charAnimFolder = cutsceneFolder:FindFirstChild("CharactersAnimation")
	local camAnimFolder = cutsceneFolder:FindFirstChild("CameraAnimation")
	local camRigFolder = cutsceneFolder:FindFirstChild("CameraRig")

	self.CharacterTrack = CharacterAnimator.new(charactersFolder, charAnimFolder)

	-- 카메라는 선택: CameraRig + CameraAnimation 둘 다 있을 때만
	local camAnim = camAnimFolder and camAnimFolder:FindFirstChildOfClass("Animation")
	if camRigFolder and camAnim then
		self.CameraTrack = CameraAnimationPlayer.new()
		self._camRigFolder = camRigFolder
		self._camAnim = camAnim
	end

	-- 종료 타이머 상태
	self._finishThread = nil
	self._finishStart = nil
	self._remaining = nil

	-- 생성 즉시 로드 시작
	task.spawn(function()
		self.CharacterTrack:Prepare(self.Display)
		if self.CameraTrack then
			self.CameraTrack:Prepare(self.Display, self._camRigFolder, self._camAnim)
		end
		self:_captureAuthored()
		if self.Origin then
			self:_applyPlacement(self.Origin)
		end
		self:_computeDuration()
		self.IsLoaded = true
		self.Loaded:Fire()
	end)

	return self
end

function Cutscene:_computeDuration()
	if self.Length then
		self.Duration = self.Length
		return
	end
	local d = self.CharacterTrack:GetDuration()
	if self.CameraTrack then
		d = math.max(d, self.CameraTrack:GetDuration())
	end
	self.Duration = d
end

function Cutscene:GetCharacters()
	return self.CharacterTrack:GetCharacters()
end

function Cutscene:GetDuration()
	return self.Duration
end

function Cutscene:GetCameraRig()
	return self.CameraTrack and self.CameraTrack:GetRig() or nil
end

-- 로드 직후 각 배치 대상(캐릭터/리그)의 원본 Pivot 저장(재생 반복 시 기준)
function Cutscene:_captureAuthored()
	self._placeables = {}
	for _, model in pairs(self.CharacterTrack:GetCharacters()) do
		self:_addPlaceable(model)
	end
	local rig = self.CameraTrack and self.CameraTrack:GetRig()
	if rig then
		self:_addPlaceable(rig)
	end
end

function Cutscene:_addPlaceable(model)
	if not (model and model:IsA("Model")) then return end
	table.insert(self._placeables, {
		Model = model,
		Pivot = model:GetPivot(),
	})
end

-- origin 기준으로 원본 위치를 재배치(원본 위치는 월드 원점 기준 오프셋으로 간주)
function Cutscene:_applyPlacement(origin)
	if not self._placeables then return end
	for _, p in ipairs(self._placeables) do
		p.Model:PivotTo(origin * p.Pivot)
	end
end

function Cutscene:_startFinishTimer(remaining)
	self._remaining = math.max(0, remaining)
	self._finishStart = os.clock()
	self._finishThread = task.delay(self._remaining, function()
		self._finishThread = nil  -- 이미 실행됨: 이후 _stopFinishTimer가 자기자신을 취소하지 않도록 참조 제거
		if self.IsPlaying then
			self:_finish()
		end
	end)
end

function Cutscene:_stopFinishTimer()
	-- 자기 자신(타이머 콜백 스레드)을 취소하는 것 방지
	if self._finishThread and self._finishThread ~= coroutine.running() then
		task.cancel(self._finishThread)
	end
	self._finishThread = nil
end

function Cutscene:Play(startTime)
	if self.IsPlaying then return end
	if not self.IsLoaded then
		self.Loaded:Wait()
	end
	startTime = startTime or 0
	self.IsPlaying = true
	self.IsPaused = false

	-- 표시 대상 부모 결정(로컬이면 카메라, 아니면 workspace)
	local parent = self.TargetParent
	if parent == nil then
		parent = RunService:IsClient() and workspace.CurrentCamera or workspace
	end
	self.Display.Parent = parent

	self.CharacterTrack:Play(startTime)
	if self.CameraTrack then
		self.CameraTrack:Play(startTime)
	end

	if self.AutoFinish then
		self:_startFinishTimer(self.Duration - startTime)
	end
end

function Cutscene:Pause()
	if not self.IsPlaying or self.IsPaused then return end
	self.IsPaused = true

	self.CharacterTrack:Pause()
	if self.CameraTrack then self.CameraTrack:Pause() end

	self:_stopFinishTimer()
	if self._finishStart and self._remaining then
		local elapsed = os.clock() - self._finishStart
		self._remaining = math.max(0, self._remaining - elapsed)
	end
end

function Cutscene:Resume()
	if not self.IsPlaying or not self.IsPaused then return end
	self.IsPaused = false

	self.CharacterTrack:Resume()
	if self.CameraTrack then self.CameraTrack:Resume() end

	if self.AutoFinish then
		self:_startFinishTimer(self._remaining or 0)
	end
end

function Cutscene:Seek(t)
	t = math.clamp(t, 0, self.Duration)

	self.CharacterTrack:Seek(t)
	if self.CameraTrack then self.CameraTrack:Seek(t) end

	if not self.IsPlaying then return end
	if self.IsPaused then
		self._remaining = self.Duration - t
	elseif self.AutoFinish then
		self:_stopFinishTimer()
		self:_startFinishTimer(self.Duration - t)
	end
end

function Cutscene:Cancel()
	if not self.IsPlaying then return end
	self:_finish()
end

-- 종료의 유일한 권한: 여기서만 카메라 원상복구 + 트랙 정지 + display 해제
function Cutscene:_finish()
	if not self.IsPlaying then return end
	self.IsPlaying = false
	self.IsPaused = false
	self:_stopFinishTimer()

	self.CharacterTrack:Cancel()
	if self.CameraTrack then self.CameraTrack:Cancel() end

	-- 클론은 재사용 위해 보존, display는 숨은 홀더로 되돌림
	self.Display.Parent = self.HoldingParent

	self.Finished:Fire()
end

function Cutscene:Destroy()
	if self.IsPlaying then
		self:_finish()
	end
	self.CharacterTrack:Destroy()
	if self.CameraTrack then self.CameraTrack:Destroy() end
	if self.Display then
		self.Display:Destroy()
		self.Display = nil
	end
	self.Loaded:Destroy()
	self.Finished:Destroy()
end

return Cutscene
