--!strict
-- 클라이언트 진입점.
-- UI 마운트는 UIController 모듈에 위임한다.
-- 이후 다른 클라이언트 로직(입력, 사운드, 네트워크 등)도 여기에 추가하면 된다.

local UIController = require(script.UIController)

UIController.start()
