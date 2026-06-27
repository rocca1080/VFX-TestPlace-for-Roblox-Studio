type AnimationSet = { [string]: number }      -- 애니메이션 이름 → 애셋 ID

export type AuraAnimations = {
	basicAnimation: AnimationSet,         -- idle/walk/jump 등 어떤 조합이든 허용
	additionalAnimation: AnimationSet?,   -- 선택적
}

local Animations: { [string]: AuraAnimations } = {

	-- ResetAnimation()의 Roblox 기본 애니메이션 ID 프리셋
	["Default"] = {
		basicAnimation = {
			idle = 180435571,   -- idle.Animation1
			walk = 180426354,
			run = 180426354,
			jump = 125750702,
			fall = 180436148,
			climb = 180436334,
			sit = 178130996,
			toolnone = 182393478,
		}
	},

	["APOSTOLOS"] = {
		basicAnimation = {
			idle = 108806952478199,
		},
		additionalAnimation = {
			spin = 123788816117414
		}
	},
	["Astraios"] = {
		basicAnimation = {
			idle = 110090760499947,
		},
	},
	["ASTRAIOS_V2"] = {
		basicAnimation = {
			idle = 98572784316773,
		},
	},
	["ASTRAIOS_V2_1"] = {
		basicAnimation = {
			idle = 98572784316773,
		},
	},
	["GARGANTUA"] = {
		basicAnimation = {
			idle = 82036614659771,
		},
	},
	["rabbit"] = {
		basicAnimation = {
			idle = 109773642607364,
		},
	},
	["Warlock"] = {
		basicAnimation = {
			idle = 89091128613619,
		},
	},
	["Anima"] = {
		basicAnimation = {
			idle = 87489925622784,
		},
	},
	["Elude"] = {
		basicAnimation = {
			idle = 112453806031845,
		},
	},
	["PROLOGUE_rework"] = {
		basicAnimation = {
			idle = 111105235929512,
		},
	},
	["PROLOGUE"] = {
		basicAnimation = {
			idle = 100283673774826,
		},
	},
	["Parasol"] = {
		basicAnimation = {
			idle = 101233381441149,
			walk = 96965936208323,
		},
	},
	["Paintgun"] = {
		basicAnimation = {
			idle = 134994892070328,
			walk = 98366463075729,
		}
	},

	["SandBasket"] = {
		basicAnimation = {
			idle = 99339441531347,
			walk = 136011481992859,
		}
	},

	["Megaphone"] = {
		basicAnimation = {
			idle = 80336095048971,
		}
	},

	["hand"] = {
		basicAnimation = {
			idle = 92300103187012,
			walk = 91723268622405,
		}
	},

	["bosstest"] = {
		basicAnimation = {
			idle = 110056137127137,
		}
	},

	["SandWorm"] = {
		basicAnimation = {
			idle = 82551011118743,
			walk = 113030751374647,
		}
	},

	["SandWormV2"] = {
		basicAnimation = {
			idle = 105382745754555,
		}
	},

	["XYZAura"] = {
		basicAnimation = {
			idle = 99079263463798,
			walk = 116176283227580,
		}
	},

	["treeAura"] = {
		basicAnimation = {
			idle = 89870006429283,
		}
	},

	["Velvet"] = {
		basicAnimation = {
			idle = 122523185466708,
			walk = 75919395126491,
			jump = 133641093146774,
			fall = 127239301640306
		}
	},

	["redmoonAura"] = {
		basicAnimation = {
			idle = 126939932722870,
		}
	},
	["COTCM"] = {
		basicAnimation = {
			idle = 91065242358745
		}

	},
	["RedMoonAura2222"] = {
		basicAnimation = {
			idle = 112101789071231,
			walk = 133910610731434,
		}
	}

}


local AnimationsConfig = {
	animations = Animations,
}

function AnimationsConfig:ResetAnimation(character)
	local animate = character:WaitForChild("Animate")
	local preset = self.animations["Default"].basicAnimation

	-- Idle (Animation1/Animation2 모두 Default의 idle ID 사용)
	animate.idle.Animation1.AnimationId = "rbxassetid://" .. preset.idle
	animate.idle.Animation2.AnimationId = "rbxassetid://" .. preset.idle
	-- Walk
	animate.walk.WalkAnim.AnimationId = "rbxassetid://" .. preset.walk
	-- Run
	animate.run.RunAnim.AnimationId = "rbxassetid://" .. preset.run
	-- Jump
	animate.jump.JumpAnim.AnimationId = "rbxassetid://" .. preset.jump
	-- Fall
	animate.fall.FallAnim.AnimationId = "rbxassetid://" .. preset.fall
	-- Climb
	animate.climb.ClimbAnim.AnimationId = "rbxassetid://" .. preset.climb
	-- Sit
	animate.sit.SitAnim.AnimationId = "rbxassetid://" .. preset.sit
	-- ToolNone (도구 들고 있는 상태)
	animate.toolnone.ToolNoneAnim.AnimationId = "rbxassetid://" .. preset.toolnone
end

return AnimationsConfig
