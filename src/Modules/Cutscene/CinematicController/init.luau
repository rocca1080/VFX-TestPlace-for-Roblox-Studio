--[[
	CinematicController
	컷신 연출을 위한 효과 모듈들을 모아 제공하는 진입점.
	효과 모듈은 이 스크립트 아래에 두고 여기서 require해 노출한다.

	사용 예시:
		local Cinematic = require(...Modules.CinematicController)
		local v = Cinematic.Vignette.new(player)
]]

local module = {}

-- 효과 모듈
module.Vignette = require(script:WaitForChild("Vignette"))
module.FadeInOut = require(script:WaitForChild("FadeInOut"))
module.Letterbox = require(script:WaitForChild("Letterbox"))

return module
