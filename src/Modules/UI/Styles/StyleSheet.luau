--!strict
-- UI 공통 스타일. StyleSheet/StyleRule(태그 셀렉터) + StyleLink로 적용한다.
-- 시각 속성(색/투명도/텍스트크기)은 여기서 관리하고, 컴포넌트는 태그만 부여한다.
-- Theme는 스타일시트로 제어하기 애매한 구조값(크기 등)이 필요할 때 컴포넌트가 참조.

local Styles = {}

local Interactive = require(script.Parent.Interactive)

-- 팔레트 / 치수
Styles.Theme = {
	color = {
		background = Color3.fromRGB(28, 30, 38),
		-- 창 배경 그래디언트 2색 (위 → 아래)
		backgroundColor1 = Color3.fromRGB(19, 20, 25),
		backgroundColor2 = Color3.fromRGB(40, 43, 56),
		titleBar = Color3.fromRGB(54, 58, 72),
		accent = Color3.fromRGB(61, 93, 255),
		button = Color3.fromRGB(54, 58, 72),
		text = Color3.fromRGB(227, 231, 240),
		inputText = Color3.fromRGB(137, 151, 177),
		close = Color3.fromRGB(213, 48, 48),
		track = Color3.fromRGB(54, 58, 72),
		knob = Color3.fromRGB(235, 238, 245),
		shadow = Color3.fromRGB(0, 0, 0),
		outlineColor1 = Color3.fromRGB(128, 141, 165),
		outlineColor2 = Color3.fromRGB(128, 141, 165),
	},
	dim = {
		titleBarHeight = 28,
		resizeHandle = 16,
		corner = UDim.new(0, 5),
		cornerRound = UDim.new(1, 0), -- 완전히 둥근(원형/알약) 코너
		panelPadding = UDim.new(0, 5), -- 패널/팝업 컨테이너 안쪽 여백 (B 역할 통일 토큰)
		gap = UDim.new(0, 5),
		shadowBlur = UDim.new(0, 25),
		shadowTransparency = 0.5,
		scrollbarThickness = 3;
		outlineThickness = 2,
		imagePadding = 4, -- 이미지 버튼 안 아이콘 여백 (버튼 크기는 유지, 아이콘만 줄임)
		inputPadding = 6, -- 입력란(TextBox) 안쪽 텍스트 여백
		dividerThickness = 1, -- 구분선 두께(px)
	},
}

-- 태그 셀렉터별 시각 속성 규칙
local RULES: { [string]: { [string]: any } } = {
	
	[".Window"] = {
		-- 배경색은 흰색으로 두고, 실제 색은 Window의 UIGradient(backgroundColor1/2)가 입힌다.
		-- (UIGradient는 BackgroundColor3에 곱해지므로, 흰색이어야 그래디언트 색이 정확히 보임)
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.1, BorderSizePixel = 0
	},

	[".TitleBar"] = { 
		BackgroundColor3 = Styles.Theme.color.titleBar, 
		BorderSizePixel = 0 
	},

	[".TitleText"] = {
		TextColor3 = Styles.Theme.color.text,
		BackgroundTransparency = 1,
		TextSize = 14,
		FontFace = Font.fromEnum(Enum.Font.GothamBold), -- 타이틀바 텍스트 볼드
	},

	["Icon"] = {
		ImageColor3 = Styles.Theme.color.text, 
	},

	[".CloseButton"] = { 
		BackgroundColor3 = Styles.Theme.color.close, 
		BorderSizePixel = 0, 
		TextSize = 16,
		Size = UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		LayoutOrder = 999
	},

	[".WindowContent"] = { 
		BackgroundTransparency = 1 
	},

	[".ResizeHandle"] = { 
		BackgroundColor3 = Styles.Theme.color.accent, 
		BackgroundTransparency = 0.4, 
		BorderSizePixel = 0 
	},

	[".TopBar"] = { 
		BackgroundColor3 = Styles.Theme.color.titleBar, 
		BackgroundTransparency = 0.1, 
		BorderSizePixel = 0 
	},

	[".Btn"] = { 
		BackgroundColor3 = Styles.Theme.color.button, 
		TextColor3 = Styles.Theme.color.text, 
		BorderSizePixel = 0, 
		TextSize = 14 
	},

	[".LabelText"] = {
		TextColor3 = Styles.Theme.color.text,
		BackgroundTransparency = 1,
		TextSize = 13
	},

	-- 필드 이름 라벨 전용: 칸을 넘치면 끝을 …로 말줄임 (LabelText와 함께 사용)
	[".FieldLabel"] = {
		TextTruncate = Enum.TextTruncate.AtEnd,
	},

	[".SliderTrack"] = { 
		BackgroundColor3 = Styles.Theme.color.track, 
		BorderSizePixel = 0 
	},

	[".SliderFill"] = { 
		BackgroundColor3 = Styles.Theme.color.accent, 
		BorderSizePixel = 0 
	},

	[".SliderKnob"] = {
		BackgroundColor3 = Styles.Theme.color.knob,
		BorderSizePixel = 0
	},

	[".Input"] = {
		BackgroundColor3 = Styles.Theme.color.button,
		TextColor3 = Styles.Theme.color.inputText,
		BorderSizePixel = 0,
		TextSize = 13,
		ClipsDescendants = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
	},

	[".Checkbox"] = {
		BackgroundColor3 = Styles.Theme.color.button,
		BorderSizePixel = 0
	},

	[".CheckMark"] = {
		BackgroundColor3 = Styles.Theme.color.accent,
		BorderSizePixel = 0
	},

	[".Swatch"] = {
		BorderSizePixel = 0
	},

	[".UIDivider"] = {
		BackgroundColor3 = Styles.Theme.color.track,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
	},

	[".EnumOption"] = {
		BackgroundColor3 = Styles.Theme.color.track,
		TextColor3 = Styles.Theme.color.text,
		BorderSizePixel = 0,
		TextSize = 13,
		ClipsDescendants = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
	},

}

-- 상호작용(hover/press) 상태 스타일. Interactive 바인더가 RULES(base) ↔ 여기 값 사이를 트윈한다.
-- 키는 RULES와 동일한 태그 셀렉터(".Btn" 등). 각 항목: transition(TweenInfo) + hover/press 속성표.
Styles.States = {
	[".Btn"] = {
		transition = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		hover = { BackgroundColor3 = Styles.Theme.color.accent },
	},
	[".CloseButton"] = {
		transition = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		hover = { BackgroundTransparency = 0 },
	},
	-- 창 애니메이션들 (attribute 토글). 한 태그에 여러 토글 가능.
	[".Window"] = {
		toggles = {
			-- 열기/닫기: "Open" → 크기(UIScale) 0↔1 (생명주기)
			{
				attribute = "Open",
				enterTransition = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				exitTransition = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				on = { Scale = 1 },
				off = { Scale = 0 },
				manageVisible = true, -- on이면 Visible=true(트윈 전), off면 트윈 후 Visible=false
			},
			-- 누름(타이틀바/리사이즈): "Pressed" → 외곽선 흰색 + 그림자 accent/불투명 (자손 타게팅)
			{
				attribute = "Pressed",
				transition = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				targets = {
					-- 그림자: accent 색 + 투명도 0 (누름) / 원래 검정 + 기본 투명도 (뗌) — 트윈
					{
						find = { "UIShadow" },
						on = { Color = Styles.Theme.color.accent, Transparency = 0 },
						off = { Color = Styles.Theme.color.shadow, Transparency = Styles.Theme.dim.shadowTransparency },
					},
					-- 외곽선 색: accent (누름) / 단색 outline (뗌) — 그래디언트 없이 stroke.Color 직접 트윈
					{
						find = { "UIStroke" },
						on = { Color = Styles.Theme.color.accent },
						off = { Color = Styles.Theme.color.outlineColor1 },
					},
				},
			},
		},
	},
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

	-- hover/press 상호작용 스타일 바인더 시동 (태그 인스턴스를 자동 포착해 트윈 적용)
	Interactive.bind(RULES, Styles.States)

	return sheet
end

return Styles
