--!strict
-- 레이아웃 헬퍼: 자식 배열의 인덱스 순서대로 LayoutOrder를 자동 부여한다.
--   UIListLayout(SortOrder=LayoutOrder) 기준 "코드에 쓴 순서 = 화면 순서"를 보장한다.
--   - step(기본 10): 값 사이 간격. 나중에 중간 삽입 여지를 남긴다.
--   - 이미 LayoutOrder가 명시(0이 아님)된 자식은 건드리지 않는다(명시값 우선).
--   같은 배열을 그대로 반환하므로 `ScrollPanel.new(ordered({...}))`처럼 드롭인 가능.

local function ordered(children: { GuiObject }, step: number?): { GuiObject }
	local s = step or 10
	for i, child in children do
		if child.LayoutOrder == 0 then
			child.LayoutOrder = i * s
		end
	end
	return children
end

return ordered
