--!strict
-- LightingManager: 키 하나로 라이팅 룩(스칼라 속성 + 인스턴스 세트)을 적용한다. 클라이언트 전용.
--
-- 적용 대상은 두 축으로 나뉜다.
--   · LightingDB[key]                       → Lighting 서비스의 스칼라 속성
--   · ReplicatedStorage.Asset.LightingSetting/[key]/ → 인스턴스 세트 (Lighting/ 이펙트, Clouds/ 구름)
--
-- 규칙:
--   · 한쪽(DB 또는 폴더)이 통째로 없으면 그 축은 건드리지 않는다(보존).
--   · 폴더가 존재하면 인스턴스 레이어를 "소유"하므로, 항상 비운 뒤 존재하는 하위만 재주입한다.
--     → 예) Default(폴더 O, Lighting O, Clouds X) = 이펙트 갱신 + 기존 구름 제거.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain

local LightingDB = require(script.Parent.Database.LightingDB)

local SETTINGS_ROOT = ReplicatedStorage:WaitForChild("Asset"):WaitForChild("LightingSetting")
local SKY_ROOT = ReplicatedStorage:WaitForChild("Asset"):WaitForChild("Sky")

local LightingManager = {}

-- 현재 적용된 프리셋 키. 부분 적용 누적으로 실제 화면과 완전히 일치하지 않을 수 있음(편집 툴 특성상 허용).
local currentKey: string? = nil

--// ① LightingDB 프리셋의 스칼라 속성을 Lighting 서비스에 적용
local function applyDatabaseSettings(preset: { [string]: any })
	for prop, value in preset do
		-- 쓰기 실패(잘못된 키 / RobloxScriptSecurity 등)는 조용히 삼키지 않고 경고로 노출
		local ok, err = pcall(function()
			(Lighting :: any)[prop] = value
		end)
		if not ok then
			warn(`[LightingManager] '{prop}' 속성 적용 실패: {err}`)
		end
	end
end

--// ② 세팅으로 적용됐던 인스턴스 레이어를 비운다 (Lighting 자식 전체 + Terrain의 Clouds)
--    Clouds는 싱글톤이라 클래스로 특정 가능 → Terrain의 보호 대상(복셀 등)은 건드리지 않는다.
local function clearAppliedInstances()
	for _, child in Lighting:GetChildren() do
		child:Destroy()
	end

	local clouds = Terrain:FindFirstChildOfClass("Clouds")
	if clouds then
		clouds:Destroy()
	end
end

--// ③ LightingSetting/[key] 폴더의 인스턴스 세트를 적용한다. (folder는 non-nil 보장)
local function applySettingFolder(folder: Instance)
	-- 폴더가 존재하면 인스턴스 레이어를 소유 → 항상 먼저 비운다(존재하는 하위만 이어서 재주입).
	clearAppliedInstances()

	local lightingFolder = folder:FindFirstChild("Lighting")
	if lightingFolder then
		for _, inst in lightingFolder:GetChildren() do
			-- 반드시 Clone (원본 reparent 시 DB 애셋이 소모됨)
			inst:Clone().Parent = Lighting
		end
	end

	local cloudsFolder = folder:FindFirstChild("Clouds")
	if cloudsFolder then
		local clouds = cloudsFolder:FindFirstChildOfClass("Clouds")
		if clouds then
			clouds:Clone().Parent = Terrain
		end
	end
end

--// 키에 해당하는 라이팅 룩을 적용한다. 성공 여부를 반환.
function LightingManager.Apply(key: string): boolean
	local preset = LightingDB[key]
	local folder = SETTINGS_ROOT:FindFirstChild(key)

	-- 양쪽 모두 없으면 유효하지 않은 키
	if not preset and not folder then
		warn(`[LightingManager] 알 수 없는 라이팅 키: "{key}"`)
		return false
	end

	if preset then
		applyDatabaseSettings(preset :: any)
	end

	if folder then
		applySettingFolder(folder)
	end

	currentKey = key
	return true
end

--// 이름으로 스카이를 찾아 Lighting에 적용한다. Sky는 싱글톤이라 기존 것을 교체. 성공 여부 반환.
function LightingManager.ApplySky(name: string): boolean
	local sky = SKY_ROOT:FindFirstChild(name)
	if not sky or not sky:IsA("Sky") then
		warn(`[LightingManager] 알 수 없는 스카이: "{name}"`)
		return false
	end

	-- 기존 Sky 제거 (Lighting은 Sky 하나만 활성)
	local existing = Lighting:FindFirstChildOfClass("Sky")
	if existing then
		existing:Destroy()
	end

	-- 반드시 Clone (원본 reparent 시 애셋 소모)
	sky:Clone().Parent = Lighting
	return true
end

--// 사용 가능한 프리셋 키 목록 (UI 드롭다운용). 안정적인 순서를 위해 정렬.
function LightingManager.GetPresetNames(): { string }
	local names = {}
	for key in LightingDB do
		table.insert(names, key)
	end
	table.sort(names)
	return names
end

--// 사용 가능한 스카이 이름 목록 (UI 드롭다운용). 안정적인 순서를 위해 정렬.
function LightingManager.GetSkyNames(): { string }
	local names = {}
	for _, child in SKY_ROOT:GetChildren() do
		if child:IsA("Sky") then
			table.insert(names, child.Name)
		end
	end
	table.sort(names)
	return names
end

--// Terrain의 Clouds 표시를 켜고 끈다. Enabled 속성만 토글하므로 인스턴스는 보존됨.
--   Clouds가 없으면 false 반환(끌 것도 없음).
function LightingManager.SetCloudsEnabled(enabled: boolean): boolean
	local clouds = Terrain:FindFirstChildOfClass("Clouds") :: Clouds?
	if not clouds then
		return false
	end
	clouds.Enabled = enabled
	return true
end

--// 현재 Clouds 표시 상태. Clouds 인스턴스가 없으면 nil.
function LightingManager.GetCloudsEnabled(): boolean?
	local clouds = Terrain:FindFirstChildOfClass("Clouds") :: Clouds?
	if not clouds then
		return nil
	end
	return clouds.Enabled
end

--// 현재 적용된 키
function LightingManager.GetCurrentKey(): string?
	return currentKey
end

--// 인스턴스 레이어를 비운다 (공개 리셋). 스칼라 속성은 건드리지 않음.
function LightingManager.Clear()
	clearAppliedInstances()
	currentKey = nil
end

return LightingManager
