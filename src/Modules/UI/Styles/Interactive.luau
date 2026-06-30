--!strict
-- 범용 상호작용/애니메이션 바인더.
--   StyleSheet의 States(태그별 애니메이션 선언)를 런타임에 적용한다.
--   CollectionService 태그로 인스턴스를 자동 포착 → 선언된 트리거의 이벤트를 직접 연결 → TweenService로 보간.
--
-- 지원 트리거 (한 태그가 여러 개 동시 가능):
--   • hover / press : 포인터 이벤트(MouseEnter/Leave, InputBegan/Ended). base ↔ 상태 사이를 트윈.
--   • toggle        : attribute(boolean) 변경. on/off 속성 사이를 트윈. (창 열기/닫기 등 생명주기)
--
-- 특수 속성 키 `Scale`: 인스턴스 직속 UIScale("_AnimScale")을 만들어 트윈한다.
--   (UISizeConstraint 등으로 Size를 직접 줄이기 어려운 경우 렌더 크기를 0↔1로 키우는 용도)
-- toggle.manageVisible=true: on이면 Visible=true(트윈 전), off면 트윈 후 Visible=false.

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Interactive = {}

local DEFAULT_TRANSITION = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INSTANT = TweenInfo.new(0)

-- 인스턴스 직속 UIScale을 찾거나 만든다 (Scale 트윈용)
local function getAnimScale(inst: GuiObject): UIScale
	local existing = inst:FindFirstChild("_AnimScale")
	if existing and existing:IsA("UIScale") then
		return existing
	end
	local s = Instance.new("UIScale")
	s.Name = "_AnimScale"
	s.Scale = 1
	s.Parent = inst
	return s
end

-- props에서 Scale은 UIScale로, 나머지는 인스턴스로 나눠 트윈한다. 대표 트윈을 반환.
local function playProps(inst: GuiObject, scaleRef: UIScale?, props: { [string]: any }, tween: TweenInfo): Tween?
	local instProps: { [string]: any } = {}
	local scaleTarget: number? = nil
	for k, v in props do
		if k == "Scale" then
			scaleTarget = v
		else
			instProps[k] = v
		end
	end

	local primary: Tween? = nil
	if scaleRef and scaleTarget ~= nil then
		local t = TweenService:Create(scaleRef, tween, { Scale = scaleTarget })
		t:Play()
		primary = t
	end
	if next(instProps) ~= nil then
		local t = TweenService:Create(inst, tween, instProps)
		t:Play()
		primary = primary or t
	end
	return primary
end

-- ── 포인터(hover/press) ──
local function bindPointer(inst: GuiObject, ruleProps: { [string]: any }?, stateDef: { [string]: any })
	local transition = stateDef.transition or DEFAULT_TRANSITION

	local managed: { [string]: boolean } = {}
	for _, stateName in { "hover", "press" } do
		local props = stateDef[stateName]
		if props then
			for key in props :: { [string]: any } do
				managed[key] = true
			end
		end
	end

	local base: { [string]: any } = {}
	for prop in managed do
		local v = ruleProps and ruleProps[prop]
		if v == nil then
			v = (inst :: any)[prop]
		end
		base[prop] = v
		;(inst :: any)[prop] = v -- base 직접 적용 (트윈 시작점 일치)
	end

	local hovering = false
	local pressing = false
	local currentTween: Tween? = nil

	local function refresh()
		local target: { [string]: any } = table.clone(base)
		if hovering and stateDef.hover then
			for k, v in stateDef.hover do target[k] = v end
		end
		if pressing and stateDef.press then
			for k, v in stateDef.press do target[k] = v end
		end
		if currentTween then currentTween:Cancel() end
		currentTween = playProps(inst, nil, target, transition)
	end

	local conns: { RBXScriptConnection } = {}
	table.insert(conns, inst.MouseEnter:Connect(function() hovering = true; refresh() end))
	table.insert(conns, inst.MouseLeave:Connect(function() hovering = false; pressing = false; refresh() end))
	table.insert(conns, inst.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			pressing = true; refresh()
		end
	end))
	table.insert(conns, inst.InputEnded:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			pressing = false; refresh()
		end
	end))
	table.insert(conns, inst.Destroying:Connect(function()
		if currentTween then currentTween:Cancel() end
		for _, c in conns do c:Disconnect() end
	end))
end

-- find 체인(클래스명 배열)을 따라 자손을 찾는다. 예: {"UIStroke","UIGradient"} → root>UIStroke>UIGradient
local function findTarget(inst: GuiObject, chain: { string }): Instance?
	local cur: Instance? = inst
	for _, cls in chain do
		if not cur then return nil end
		cur = cur:FindFirstChildWhichIsA(cls)
	end
	return cur
end

-- ── attribute 토글 (on/off). self(태그 인스턴스 속성) + targets(자손 인스턴스)까지 애니메이트 ──
local function bindToggle(inst: GuiObject, def: { [string]: any })
	local attr: string = def.attribute
	local enterT = def.enterTransition or def.transition or DEFAULT_TRANSITION
	local exitT = def.exitTransition or def.transition or DEFAULT_TRANSITION

	-- self: 태그 인스턴스 자신의 on/off 속성 (Scale은 UIScale로)
	local hasSelf = def.on ~= nil or def.off ~= nil
	local usesScale = (def.on and def.on.Scale ~= nil) or (def.off and def.off.Scale ~= nil)
	local scaleRef: UIScale? = if usesScale then getAnimScale(inst) else nil

	-- targets: 자손 인스턴스들 (find 체인으로 해석, 한 번만)
	local targets: { { inst: Instance, on: any, off: any, instant: boolean } } = {}
	if def.targets then
		for _, t in def.targets do
			local ti = findTarget(inst, t.find)
			if ti then
				table.insert(targets, { inst = ti, on = t.on, off = t.off, instant = t.instant == true })
			end
		end
	end

	local selfTween: Tween? = nil
	local selfConn: RBXScriptConnection? = nil
	local targetTweens: { Tween } = {}

	local function apply(useOn: boolean, tween: TweenInfo, isOff: boolean)
		if selfTween then selfTween:Cancel() end
		if selfConn then selfConn:Disconnect(); selfConn = nil end
		for _, tw in targetTweens do tw:Cancel() end
		targetTweens = {}

		-- self
		if hasSelf then
			local props = (if useOn then def.on else def.off) or {}
			local primary = playProps(inst, scaleRef, props, tween)
			selfTween = primary
			if isOff and def.manageVisible and primary then
				selfConn = primary.Completed:Connect(function(playbackState)
					if playbackState == Enum.PlaybackState.Completed then
						(inst :: any).Visible = false
					end
				end)
			end
		end

		-- targets (자손)
		for _, t in targets do
			local props = if useOn then t.on else t.off
			if props then
				if t.instant then
					for k, val in props :: { [string]: any } do
						(t.inst :: any)[k] = val
					end
				else
					local tw = TweenService:Create(t.inst, tween, props)
					tw:Play()
					table.insert(targetTweens, tw)
				end
			end
		end
	end

	-- on/off 속성을 트윈 없이 즉시(동기적으로) 적용한다. (초기 베이스라인 세팅용)
	-- playProps는 INSTANT라도 비동기로 적용되므로, 직후 enter 트윈에 캔슬당해 시작점이 어긋날 수 있다.
	-- 따라서 초기 베이스라인은 트윈이 아니라 속성을 직접 써서 동기적으로 맞춘다.
	local function snap(useOn: boolean)
		local props = if useOn then def.on else def.off
		if props then
			for k, v in props :: { [string]: any } do
				if k == "Scale" then
					if scaleRef then scaleRef.Scale = v end
				else
					(inst :: any)[k] = v
				end
			end
		end
		for _, t in targets do
			local p = if useOn then t.on else t.off
			if p then
				for k, v in p :: { [string]: any } do
					(t.inst :: any)[k] = v
				end
			end
		end
	end

	local function refresh(animate: boolean)
		local on = inst:GetAttribute(attr) == true
		local tween = if animate then (if on then enterT else exitT) else INSTANT
		if on and def.manageVisible then (inst :: any).Visible = true end
		apply(on, tween, not on)
	end

	-- 초기화: 켜진 채 생성됐으면 off 베이스라인을 즉시 깐 뒤 enter 트윈을 재생하고,
	-- 꺼진 상태면 트윈 없이 즉시 off로 스냅한다.
	-- → 바인딩(task.defer) 시점보다 먼저 Open=true로 만들어진 창(팝업 피커 등)도
	--    "변화"를 못 봐 스냅되던 문제 없이 열기 애니메이션이 자동 적용된다.
	if inst:GetAttribute(attr) == true then
		snap(false) -- off 베이스라인(Scale 0 등) 즉시 적용
		refresh(true) -- Visible=true + enter 트윈
	else
		refresh(false) -- 초기 상태(트윈 없이)
	end
	local changedConn = inst:GetAttributeChangedSignal(attr):Connect(function() refresh(true) end)
	inst.Destroying:Connect(function()
		if selfTween then selfTween:Cancel() end
		if selfConn then selfConn:Disconnect() end
		for _, tw in targetTweens do tw:Cancel() end
		changedConn:Disconnect()
	end)
end

-- rules: StyleSheet의 RULES (base 값 출처), states: StyleSheet의 States
function Interactive.bind(rules: { [string]: any }, states: { [string]: any })
	for tagName, def in states do
		local tag = (tagName:gsub("^%.", "")) -- ".Btn" → "Btn"
		local ruleProps = rules[tagName]
		local function onAdded(inst: Instance)
			if not inst:IsA("GuiObject") then return end
			-- DI 생성(속성/태그/부모 설정)이 끝난 뒤 바인딩되도록 defer
			task.defer(function()
				if def.hover or def.press then
					bindPointer(inst, ruleProps, def)
				end
				if def.toggles then
					for _, t in def.toggles do
						bindToggle(inst, t)
					end
				end
			end)
		end
		for _, inst in CollectionService:GetTagged(tag) do
			onAdded(inst)
		end
		CollectionService:GetInstanceAddedSignal(tag):Connect(onAdded)
	end
end

return Interactive
