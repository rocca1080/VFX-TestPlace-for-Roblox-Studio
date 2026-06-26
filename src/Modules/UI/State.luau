--!strict
-- UI 전역 상태. Artworks.Observable로 만들어 Observer:bindToObservable로 UI에 바인딩한다.
--   masterHidden     : 모든 창 숨기기 토글
--   lightingVisible  : 라이팅 세팅 창 표시 여부
--   auraVisible      : Aura 테스트 창 표시 여부
--   cutsceneVisible  : 컷신 테스트 창 표시 여부
--
-- 참고: DeclarativeInstance.reactiveValue는 현재 Observer API와 메서드명이 맞지 않아
--       (subscribeKey 등 부재) 동작하지 않으므로, 바인딩은 Observer:bindToObservable를 사용한다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Artworks = require(ReplicatedStorage.Modules.Artworks)
local Observable = Artworks.Observable

local State = {}

function State.new()
	return Observable({
		masterHidden = false,
		lightingVisible = false,
		auraVisible = false,
		cutsceneVisible = false,
	})
end

return State
