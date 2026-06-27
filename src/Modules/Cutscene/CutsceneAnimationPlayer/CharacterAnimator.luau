--[[
	CharacterAnimator — 캐릭터 클론 + 애니메이션 트랙을 관리하는 트랙.
	Cutscene의 하위 모듈. 공통 Track 인터페이스(Prepare/GetDuration/Play/Pause/Resume/Seek/Cancel/Destroy) 구현.
]]
local CharacterAnimator = {}
CharacterAnimator.__index = CharacterAnimator

local LOAD_TIMEOUT = 10  -- 초

function CharacterAnimator.new(charactersFolder, charAnimFolder)
	return setmetatable({
		CharactersFolder = charactersFolder,
		CharAnimFolder = charAnimFolder,
		Characters = {},   -- name -> clone
		Tracks = {},       -- { { Clone=, Track= }, ... }
		TrackSpeeds = {},  -- Pause 시 원래 속도 보관
		IsPlaying = false,
		IsPaused = false,
	}, CharacterAnimator)
end

-- 생성 시: 클론 + Animator + LoadAnimation + track.Length>0 대기
function CharacterAnimator:Prepare(displayFolder)
	if not self.CharactersFolder then return end
	local toLoad = {}

	for _, original in ipairs(self.CharactersFolder:GetChildren()) do
		if original:IsA("Model") then
			local clone = original:Clone()
			clone.Parent = displayFolder
			self.Characters[original.Name] = clone

			local controller = clone:FindFirstChildOfClass("Humanoid") or clone:FindFirstChildOfClass("AnimationController")
			if controller and self.CharAnimFolder then
				local animator = controller:FindFirstChildOfClass("Animator")
				if not animator then
					animator = Instance.new("Animator")
					animator.Parent = controller
				end
				local anim = self.CharAnimFolder:FindFirstChild(original.Name)
				if anim and anim:IsA("Animation") then
					local track = animator:LoadAnimation(anim)
					track.Looped = false
					table.insert(self.Tracks, { Clone = clone, Track = track })
					table.insert(toLoad, track)
				end
			end
		end
	end

	-- 모든 트랙의 키프레임이 로드될 때까지(Length>0) 대기
	local t0 = os.clock()
	while os.clock() - t0 < LOAD_TIMEOUT do
		local allReady = true
		for _, track in ipairs(toLoad) do
			if track.Length <= 0 then
				allReady = false
				break
			end
		end
		if allReady then break end
		task.wait()
	end
end

function CharacterAnimator:GetCharacters()
	return self.Characters
end

function CharacterAnimator:GetDuration()
	local d = 0
	for _, e in ipairs(self.Tracks) do
		if e.Track.Length > d then
			d = e.Track.Length
		end
	end
	return d
end

function CharacterAnimator:Play(startTime)
	if self.IsPlaying then return end
	self.IsPlaying = true
	self.IsPaused = false
	for _, e in ipairs(self.Tracks) do
		e.Track:Play(0)
		if startTime and startTime > 0 then
			e.Track.TimePosition = startTime
		end
	end
end

function CharacterAnimator:Pause()
	if not self.IsPlaying or self.IsPaused then return end
	self.IsPaused = true
	self.TrackSpeeds = {}
	for _, e in ipairs(self.Tracks) do
		self.TrackSpeeds[e.Track] = e.Track.Speed
		e.Track:AdjustSpeed(0)
	end
end

function CharacterAnimator:Resume()
	if not self.IsPlaying or not self.IsPaused then return end
	self.IsPaused = false
	for _, e in ipairs(self.Tracks) do
		e.Track:AdjustSpeed(self.TrackSpeeds[e.Track] or 1)
	end
	table.clear(self.TrackSpeeds)
end

function CharacterAnimator:Seek(t)
	for _, e in ipairs(self.Tracks) do
		e.Track.TimePosition = math.clamp(t, 0, e.Track.Length)
	end
end

function CharacterAnimator:Cancel()
	if not self.IsPlaying then return end
	self.IsPlaying = false
	self.IsPaused = false
	for _, e in ipairs(self.Tracks) do
		if e.Track.IsPlaying then
			e.Track:Stop()
		end
	end
end

function CharacterAnimator:Destroy()
	self:Cancel()
	-- 클론은 display 폴더에 있고 Cutscene이 폴더를 파괴함. 여기선 참조만 정리.
	table.clear(self.Characters)
	table.clear(self.Tracks)
	table.clear(self.TrackSpeeds)
end

return CharacterAnimator
