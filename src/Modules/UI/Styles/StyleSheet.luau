--!strict
-- UI 공통 스타일. StyleSheet/StyleRule(태그 셀렉터) + StyleLink로 적용한다.
-- 시각 속성(색/투명도/텍스트크기)은 여기서 관리하고, 컴포넌트는 태그만 부여한다.
-- Theme는 스타일시트로 제어하기 애매한 구조값(크기 등)이 필요할 때 컴포넌트가 참조.

local Styles = {}

-- 팔레트 / 치수
Styles.Theme = {
	color = {
		background = Color3.fromRGB(28, 30, 38),
		titleBar = Color3.fromRGB(38, 41, 52),
		accent = Color3.fromRGB(86, 130, 246),
		button = Color3.fromRGB(54, 58, 72),
		text = Color3.fromRGB(235, 238, 245),
		close = Color3.fromRGB(200, 70, 70),
		track = Color3.fromRGB(54, 58, 72),
		knob = Color3.fromRGB(235, 238, 245),
	},
	dim = {
		titleBarHeight = 28,
		resizeHandle = 16,
		corner = UDim.new(0, 6),
		gap = 6,
	},
}

-- 태그 셀렉터별 시각 속성 규칙
local RULES: { [string]: { [string]: any } } = {
	[".Window"] = { BackgroundColor3 = Styles.Theme.color.background, BackgroundTransparency = 0.05, BorderSizePixel = 0 },
	[".TitleBar"] = { BackgroundColor3 = Styles.Theme.color.titleBar, BorderSizePixel = 0 },
	[".TitleText"] = { TextColor3 = Styles.Theme.color.text, BackgroundTransparency = 1, TextSize = 14 },
	[".CloseButton"] = { BackgroundColor3 = Styles.Theme.color.close, TextColor3 = Styles.Theme.color.text, BorderSizePixel = 0, TextSize = 16 },
	[".WindowContent"] = { BackgroundTransparency = 1 },
	[".ResizeHandle"] = { BackgroundColor3 = Styles.Theme.color.accent, BackgroundTransparency = 0.4, BorderSizePixel = 0 },
	[".TopBar"] = { BackgroundColor3 = Styles.Theme.color.titleBar, BackgroundTransparency = 0.1, BorderSizePixel = 0 },
	[".Btn"] = { BackgroundColor3 = Styles.Theme.color.button, TextColor3 = Styles.Theme.color.text, BorderSizePixel = 0, TextSize = 14 },
	[".LabelText"] = { TextColor3 = Styles.Theme.color.text, BackgroundTransparency = 1, TextSize = 13 },
	[".SliderTrack"] = { BackgroundColor3 = Styles.Theme.color.track, BorderSizePixel = 0 },
	[".SliderFill"] = { BackgroundColor3 = Styles.Theme.color.accent, BorderSizePixel = 0 },
	[".SliderKnob"] = { BackgroundColor3 = Styles.Theme.color.knob, BorderSizePixel = 0 },
}

-- StyleSheet 인스턴스를 만들어 반환한다.
local function createStyleSheet(): StyleSheet
	local sheet = Instance.new("StyleSheet")
	sheet.Name = "UIStyleSheet"

	for selector, properties in RULES do
		local rule = Instance.new("StyleRule")
		rule.Selector = selector
		rule:SetProperties(properties)
		rule.Parent = sheet
	end

	return sheet
end

-- target(보통 ScreenGui)에 스타일시트를 생성·연결한다.
function Styles.applyTo(target: Instance): StyleSheet
	local sheet = createStyleSheet()
	sheet.Parent = target

	local link = Instance.new("StyleLink")
	link.Name = "UIStyleLink"
	link.StyleSheet = sheet
	link.Parent = target

	return sheet
end

return Styles
