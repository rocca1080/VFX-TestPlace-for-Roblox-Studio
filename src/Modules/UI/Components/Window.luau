--!strict
-- 재사용 창 컴포넌트. 타이틀바 드래그 이동 / 우하단 모서리 크기 조절 / x 버튼 닫기 공통 처리.
-- 시각 스타일은 태그(StyleSheet)로, 동작은 UserInputService로 처리한다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme

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
}

local Window = {}

-- handle 위에서 드래그하면 target을 이동시킨다.
local function makeDraggable(handle: GuiObject, target: GuiObject)
	local dragging = false
	local dragStart: Vector3
	local startPos: UDim2
	local moveConn: RBXScriptConnection?
	local endConn: RBXScriptConnection?

	local function stop()
		dragging = false
		if moveConn then moveConn:Disconnect() end
		if endConn then endConn:Disconnect() end
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
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
		if moveConn then moveConn:Disconnect() end
		if endConn then endConn:Disconnect() end
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		resizing = true
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

	-- 타이틀
	local titleLabel = DI.TextLabel({
		Name = "Title",
		Text = props.Title or "Window",
		Size = UDim2.new(1, -(height + 8), 1, 0),
		Position = UDim2.fromOffset(8, 0),
		"TitleText",
	})
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local closeButton = DI.TextButton({
		Name = "Close",
		Text = "x",
		Size = UDim2.fromOffset(height - 6, height - 6),
		Position = UDim2.new(1, -(height - 3), 0, 3),
		AutoButtonColor = true,
		"CloseButton",
		DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
		Activated = function()
			if props.OnClose then props.OnClose() end
		end,
	})

	local titleBar = DI.Frame({
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, height),
		Active = true,
		"TitleBar",
		DI.UICorner({ CornerRadius = Theme.dim.corner }),
		titleLabel,
		closeButton,
	})

	-- 컨텐츠 영역 (패널이 여기로 들어옴)
	local content = DI.Frame({
		Name = "Content",
		Position = UDim2.fromOffset(0, height),
		Size = UDim2.new(1, 0, 1, -height),
		"WindowContent",
		DI.UIPadding({
			PaddingLeft = UDim.new(0, Theme.dim.gap),
			PaddingRight = UDim.new(0, Theme.dim.gap),
			PaddingTop = UDim.new(0, Theme.dim.gap),
			PaddingBottom = UDim.new(0, Theme.dim.gap),
		}),
	})

	-- 우하단 리사이즈 핸들
	local resizeHandle = DI.TextButton({
		Name = "Resize",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(Theme.dim.resizeHandle, Theme.dim.resizeHandle),
		Position = UDim2.new(1, -Theme.dim.resizeHandle, 1, -Theme.dim.resizeHandle),
		"ResizeHandle",
		DI.UICorner({ CornerRadius = UDim.new(0, 4) }),
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
		titleBar,
		content,
		resizeHandle,
	})

	makeDraggable(titleBar, root)
	makeResizable(resizeHandle, root, minSize)

	return {
		Root = root,
		Content = content,
	}
end

return Window
