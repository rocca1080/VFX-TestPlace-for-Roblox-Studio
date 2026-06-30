--!strict
-- 패딩 헬퍼: 4면을 동일한 값으로 채운 UIPadding을 한 번에 생성한다.
--   컨테이너 안쪽 여백(B 역할)처럼 4면이 같은 패딩일 때 4줄 반복을 1줄로 줄인다.
--   사용: uniformPadding(Theme.dim.panelPadding) → DI children 목록에 그대로 넣는다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local DI = Artworks.DeclarativeInstance

local function uniformPadding(amount: UDim): UIPadding
	return DI.UIPadding({
		PaddingLeft = amount,
		PaddingRight = amount,
		PaddingTop = amount,
		PaddingBottom = amount,
	})
end

return uniformPadding
