--!strict
-- UI 아이콘 이미지 에셋 모음. (StyleSheet처럼 시각 리소스를 한 곳에서 관리)
-- 컴포넌트는 하드코딩 대신 여기서 참조한다.  예) ImageLabel.Image = Icons.close
-- 값은 바로 Image 속성에 넣을 수 있게 "rbxassetid://..." 전체 문자열로 보관한다.

local Icons = {
	close = "rbxassetid://128972984735078", -- 창 닫기(X)
	check = "rbxassetid://77791898741029"
}

return Icons
