--!strict
-- 재사용 창 컴포넌트. 타이틀바 드래그 이동 / 우하단 모서리 크기 조절 / x 버튼 닫기 공통 처리.
-- 시각 스타일은 태그(StyleSheet)로, 동작은 UserInputService로 처리한다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme
local Icons = require(script.Parent.Parent.Styles.Icons)
local uniformPadding = require(script.Parent.Parent.Styles.Padding)
local ZOrder = require(script.Parent.Parent.Styles.ZOrder)

export type WindowProps = {
	Title: string?,
	Size: UDim2?,
	Position: UDim2?,
	MinSize: Vector2?,
	OnClose: (() -> ())?,
}

export type Window = {
	Root: Frame,
	Content: Frame,
	-- 닫기 애니메이션(exit 트윈) 재생 후 파괴. 호출자는 Root:Destroy() 대신 이걸 쓴다.
	Close: () -> (),
}

local Window = {}

-- 주어진 화면 좌표에서 "가장 앞에 있는(겹친 것 중 최상단)" 창 root를 찾는다.
-- InputBegan은 겹친 창 모두에서 발동하므로(관찰용 — 가려져도 sink 안 됨, 발동 순서도 보장 X),
-- 이벤트 순서에 의존하지 않고 실제 렌더 순서(GetGuiObjectsAtPosition: 앞→뒤)로 맨 앞 창만 가려낸다.
-- 창 root는 "Window" 태그로 식별한다.
local function frontWindowAt(fromObj: GuiObject, x: number, y: number): GuiObject?
	local playerGui = fromObj:FindFirstAncestorWhichIsA("PlayerGui")
	if not playerGui then
		return nil
	end
	for _, obj in (playerGui :: PlayerGui):GetGuiObjectsAtPosition(x, y) do
		local cur: Instance? = obj
		while cur do
			if cur:IsA("GuiObject") and cur:HasTag("Window") then
				return cur
			end
			cur = cur.Parent
		end
	end
	return nil
end

-- handle 위에서 드래그하면 target을 이동시킨다.
local function makeDraggable(handle: GuiObject, target: GuiObject)
	local dragging = false
	local dragStart: Vector3
	local startPos: UDim2
	local moveConn: RBXScriptConnection?
	local endConn: RBXScriptConnection?

	local function stop()
		dragging = false
		target:SetAttribute("Pressed", false) -- 누름 해제 → 외곽선/그림자 원복 (Interactive 바인더)
		if moveConn then moveConn:Disconnect() end
		if endConn then endConn:Disconnect() end
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if frontWindowAt(target, input.Position.X, input.Position.Y) ~= target then return end -- 맨 앞 창만 끌림
		dragging = true
		target:SetAttribute("Pressed", true) -- 타이틀바 누름 → 외곽선 흰색 + 그림자 강조
		dragStart = input.Position
		startPos = target.Position

		moveConn = UserInputService.InputChanged:Connect(function(moveInput)
			if not dragging then return end
			if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement and moveInput.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local delta = moveInput.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end)

		endConn = UserInputService.InputEnded:Connect(function(endInput)
			if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
				stop()
			end
		end)
	end)
end

-- handle 위에서 드래그하면 target의 크기를 조절한다. (offset 기준)
local function makeResizable(handle: GuiObject, target: GuiObject, minSize: Vector2)
	local resizing = false
	local startInput: Vector3
	local startSize: UDim2
	local moveConn: RBXScriptConnection?
	local endConn: RBXScriptConnection?

	local function stop()
		resizing = false
		target:SetAttribute("Pressed", false) -- 누름 해제 → 외곽선/그림자 원복
		if moveConn then moveConn:Disconnect() end
		if endConn then endConn:Disconnect() end
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if frontWindowAt(target, input.Position.X, input.Position.Y) ~= target then return end -- 맨 앞 창만 반응
		resizing = true
		target:SetAttribute("Pressed", true) -- 리사이즈 핸들 누름 → 외곽선 흰색 + 그림자 강조
		startInput = input.Position
		startSize = target.Size

		moveConn = UserInputService.InputChanged:Connect(function(moveInput)
			if not resizing then return end
			if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement and moveInput.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local delta = moveInput.Position - startInput
			local width = math.max(minSize.X, startSize.X.Offset + delta.X)
			local height = math.max(minSize.Y, startSize.Y.Offset + delta.Y)
			target.Size = UDim2.new(startSize.X.Scale, width, startSize.Y.Scale, height)
		end)

		endConn = UserInputService.InputEnded:Connect(function(endInput)
			if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
				stop()
			end
		end)
	end)
end

function Window.new(props: WindowProps): Window
	local minSize = props.MinSize or Vector2.new(200, 140)
	local height = Theme.dim.titleBarHeight
	local shadowBlur = Theme.dim.shadowBlur
	local shadowTransparency = Theme.dim.shadowTransparency
	local outlineThickness = Theme.dim.outlineThickness
	local imagePadding = Theme.dim.imagePadding
	local gap = Theme.dim.gap
	local outlineColor1 = Theme.color.outlineColor1
	local backgroundColor1 = Theme.color.backgroundColor1
	local backgroundColor2 = Theme.color.backgroundColor2
	local textColor = Theme.color.text

	-- 타이틀
	local titleLabel = DI.TextLabel({
		Name = "Title",
		Text = props.Title or "Window",
		Size = UDim2.new(1, 0, 1, 0),
		"TitleText",
	})
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- 닫기 버튼: 클릭 영역은 풀사이즈(투명 버튼), 아이콘은 자식 ImageLabel로 표시.
	-- UIPadding(imagePadding)이 자식 아이콘을 안쪽으로 들여 아이콘만 작아지고 클릭 영역은 유지된다.
	local closeIcon = DI.ImageLabel({
		Name = "Icon",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		"Icon"
	})
	closeIcon.Image = Icons.close

	local closeButton = DI.ImageButton({
		Name = "Close",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false, -- hover/press는 Interactive 바인더가 트윈으로 처리
		"CloseButton",
		DI.UIPadding({
			PaddingLeft = UDim.new(0, imagePadding),
			PaddingRight = UDim.new(0, imagePadding),
			PaddingTop = UDim.new(0, imagePadding),
			PaddingBottom = UDim.new(0, imagePadding),
		}),
		closeIcon,
		Activated = function()
			if props.OnClose then props.OnClose() end
		end,
	})

	local titleBar = DI.Frame({
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, height),
		Active = true,
		"TitleBar",
		DI.UIListLayout({
			Padding = gap,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		DI.UICorner({ CornerRadius = Theme.dim.corner }),
		uniformPadding(Theme.dim.panelPadding),
		titleLabel,
		closeButton,
	})

	-- 컨텐츠 영역 (패널이 여기로 들어옴). 일반 Frame.
	-- 스크롤/패딩은 패널 쪽(ScrollPanel 컴포넌트)이 담당한다.
	local content = DI.Frame({
		Name = "Content",
		Position = UDim2.fromOffset(0, height),
		Size = UDim2.new(1, 0, 1, -height),
		"WindowContent",
	})

	-- 우하단 리사이즈 핸들
	local resizeHandle = DI.TextButton({
		Name = "Resize",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(Theme.dim.resizeHandle, Theme.dim.resizeHandle),
		Position = UDim2.new(1, -Theme.dim.resizeHandle, 1, -Theme.dim.resizeHandle),
		"ResizeHandle",
		DI.UICorner({ CornerRadius = Theme.dim.corner }),
	})

	local root = DI.Frame({
		Name = props.Title or "Window",
		Size = props.Size or UDim2.fromOffset(280, 200),
		Position = props.Position or UDim2.fromOffset(60, 60),
		Active = true,
		Visible = false,
		ClipsDescendants = true,
		"Window",
		DI.UICorner({ CornerRadius = Theme.dim.corner }),
		DI.UISizeConstraint({ MinSize = minSize }),
		-- 배경 2색 그래디언트 (위→아래). 색은 StyleSheet의 backgroundColor1/2로 설정.
		DI.UIGradient({
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, backgroundColor1),
				ColorSequenceKeypoint.new(1, backgroundColor2),
			}),
		}),
		DI.UIShadow({ 
			BlurRadius = shadowBlur,
			Transparency = shadowTransparency,
		}),
		-- 외곽선: 단색(그래디언트 없음) → Color를 직접 트윈할 수 있음 (Pressed 시 accent로)
		DI.UIStroke({
			Color = outlineColor1,
			Thickness = outlineThickness,
		}),
		titleBar,
		content,
		resizeHandle,
	})

	makeDraggable(titleBar, root)
	makeResizable(resizeHandle, root, minSize)

	-- 창 아무 곳이나 누르면 최상단으로 올린다 (겹친 창 중 최상단만 반응).
	root.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if frontWindowAt(root, input.Position.X, input.Position.Y) == root then
			root.ZIndex = ZOrder.next()
		end
	end)

	-- 애니메이션 닫기: "Open"=false로 내려 Interactive 바인더의 exit 트윈을 재생시키고,
	-- 트윈 완료 시 바인더가 manageVisible로 Visible=false를 찍으면 그 신호를 받아 파괴한다.
	-- (Window가 트윈 길이를 직접 알 필요 없이 생명주기 신호에만 의존)
	local closing = false
	local function close()
		if closing then return end
		closing = true
		-- 이미 닫혀 있거나(보이지 않음) 열린 적 없으면 트윈 없이 바로 파괴
		if not root.Visible or root:GetAttribute("Open") ~= true then
			root:Destroy()
			return
		end
		root:SetAttribute("Open", false)
		local conn: RBXScriptConnection? = nil
		conn = root:GetPropertyChangedSignal("Visible"):Connect(function()
			if not root.Visible then
				if conn then conn:Disconnect() end
				root:Destroy()
			end
		end)
		-- 안전장치: 바인더가 없거나(태그 미바인딩) 트윈이 끝나지 않아도 누수 없도록 강제 파괴
		task.delay(1, function()
			if conn then conn:Disconnect() end
			if root.Parent then root:Destroy() end
		end)
	end

	return {
		Root = root,
		Content = content,
		Close = close,
	}
end

return Window
