--!strict
-- 구분선(divider). 가로로 얇은 선. 패널 항목 사이 구분용.
-- 두께는 기본값으로 Theme.dim.dividerThickness, 색/투명도는 StyleSheet의 ".Divider" 규칙에서 관리.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local Styles = require(script.Parent.Parent.Styles.StyleSheet)
local Theme = Styles.Theme

export type DividerProps = {
	LayoutOrder: number?,
	Thickness: number?, -- 생략 시 Theme.dim.dividerThickness 사용
}

local Divider = {}

function Divider.new(props: DividerProps?): Frame
	local p = props or {}
	return DI.Frame({
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, p.Thickness or Theme.dim.dividerThickness),
		BorderSizePixel = 0,
		LayoutOrder = p.LayoutOrder or 0,
		-- 태그명을 "UIDivider"로 변경: Studio 플러그인이 "Divider" 태그를 가로채 색을 덮어쓰는 충돌 회피
		"UIDivider",
	})
end

return Divider
