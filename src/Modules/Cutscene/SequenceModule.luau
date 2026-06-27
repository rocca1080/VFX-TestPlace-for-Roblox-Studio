local Sequence = {}
Sequence.__index = Sequence

--// 1. 이벤트 생성용 헬퍼 함수 \\--
function Sequence.At(time: number, action: () -> ())
	return { Type = "At", Time = time, Action = action }
end

function Sequence.Wait(delayTime: number, action: () -> ())
	return { Type = "Wait", Time = delayTime, Action = action }
end

--// 2. 시퀀스 객체 생성 \\--
function Sequence.new(eventList: {any})
	local self = setmetatable({}, Sequence)

	self.Events = {}            
	self.ActiveThreads = {}     
	self.EndThread = nil        -- 자동 종료를 담당할 쓰레드

	self.CurrentTime = 0        
	self.PlaybackState = "Stopped" 
	self.LastPlayTick = 0       

	local currentCursor = 0

	for _, eventData in ipairs(eventList) do
		if eventData.Type == "Wait" then
			currentCursor += eventData.Time
		elseif eventData.Type == "At" then
			currentCursor = eventData.Time
		end

		table.insert(self.Events, {
			TriggerTime = currentCursor,
			Action = eventData.Action,
			Completed = false
		})
	end

	table.sort(self.Events, function(a, b)
		return a.TriggerTime < b.TriggerTime
	end)

	-- 시퀀스의 총 길이 저장
	self.Duration = #self.Events > 0 and self.Events[#self.Events].TriggerTime or 0

	return self
end

--// 3. 시퀀스 제어 메서드 \\--
function Sequence:Play(startTime: number?)
	if self.PlaybackState == "Playing" then return end

	if startTime then
		self.CurrentTime = startTime
		for _, event in ipairs(self.Events) do
			event.Completed = (event.TriggerTime <= startTime)
		end
	end

	self.PlaybackState = "Playing"
	self.LastPlayTick = os.clock()

	for _, event in ipairs(self.Events) do
		if not event.Completed then
			local timeToWait = event.TriggerTime - self.CurrentTime

			if timeToWait <= 0 then
				event.Completed = true
				task.spawn(event.Action)
			else
				local thread = task.delay(timeToWait, function()
					event.Completed = true
					self.ActiveThreads[event] = nil 
					event.Action()
				end)
				self.ActiveThreads[event] = thread
			end
		end
	end

	-- 시퀀스 자동 종료 타이머 작동
	local remainingTime = self.Duration - self.CurrentTime
	if remainingTime > 0 then
		self.EndThread = task.delay(remainingTime, function()
			self:Cancel()
		end)
	else
		self:Cancel()
	end
end

function Sequence:Pause()
	if self.PlaybackState ~= "Playing" then return end
	self.PlaybackState = "Paused"

	local elapsedSincePlay = os.clock() - self.LastPlayTick
	self.CurrentTime += elapsedSincePlay

	local currentThread = coroutine.running() -- 💡 현재 실행 중인 쓰레드 확인

	for event, thread in pairs(self.ActiveThreads) do
		-- 자기 자신을 취소하는 것 방지
		if thread ~= currentThread then
			task.cancel(thread)
		end
	end
	table.clear(self.ActiveThreads)

	-- 자동 종료 타이머 멈춤
	if self.EndThread then
		if self.EndThread ~= currentThread then
			task.cancel(self.EndThread)
		end
		self.EndThread = nil
	end
end

function Sequence:Cancel()
	self.PlaybackState = "Stopped"
	self.CurrentTime = 0

	local currentThread = coroutine.running() -- 💡 현재 실행 중인 쓰레드 확인

	for event, thread in pairs(self.ActiveThreads) do
		-- 자기 자신을 취소하는 것 방지
		if thread ~= currentThread then
			task.cancel(thread)
		end
	end
	table.clear(self.ActiveThreads)

	-- 강제 취소 시 자동 종료 타이머 삭제
	if self.EndThread then
		if self.EndThread ~= currentThread then
			task.cancel(self.EndThread)
		end
		self.EndThread = nil
	end

	for _, event in ipairs(self.Events) do
		event.Completed = false
	end
end

return Sequence