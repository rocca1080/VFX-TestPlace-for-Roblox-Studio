--!strict
-- 창 스택 순서(z-order) 중앙 관리.
--   · 창을 포커스(클릭)할 때 next()로 다음 최상단 ZIndex를 받아 올린다.
--   · 드롭다운 팝업 등은 current()+오프셋으로 항상 최상단 창 위에 띄운다.

local ZOrder = {}

-- 1에서 시작: GuiObject 기본 ZIndex(1)보다 위여야 첫 클릭에 실제로 올라온다(첫 next()=2).
local top = 1

--// 다음 최상단 ZIndex (창 앞으로 가져오기용). 카운터를 1 증가시키고 그 값을 반환.
function ZOrder.next(): number
	top += 1
	return top
end

--// 현재 최상단 값. 그 위에 무언가 띄울 기준값(카운터는 변하지 않음).
function ZOrder.current(): number
	return top
end

return ZOrder
