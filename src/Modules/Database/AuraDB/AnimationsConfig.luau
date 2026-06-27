local AnimationsConfig = {
	
	
	APOSTOLOS = {
		basicAnimation = {
			idle = 108806952478199,
		},
		additionalAnimation = {
			spin = 123788816117414
		}
	},
	Astraios = {
		basicAnimation = {
			idle = 110090760499947, 
		},
	},
	ASTRAIOS_V2 = {
		basicAnimation = {
			idle = 98572784316773, 
		},
	},
	ASTRAIOS_V2_1 = {
		basicAnimation = {
			idle = 98572784316773, 
		},
	},
	GARGANTUA = {
		basicAnimation = {
			idle = 82036614659771, 
		},
	},
	rabbit = {
		basicAnimation = {
			idle = 109773642607364, 
		},
	},
	Warlock = {
		basicAnimation = {
			idle = 89091128613619, 
		},
	},
	Anima = {
		basicAnimation = {
			idle = 87489925622784, 
		},
	},
	Elude = {
		basicAnimation = {
			idle = 112453806031845, 
		},
	},
	PROLOGUE_rework = {
		basicAnimation = {
			idle = 111105235929512, 
		},
	},
	PROLOGUE = {
		basicAnimation = {
			idle = 100283673774826, 
		},
	},
	Parasol = {
		basicAnimation = {
			idle = 101233381441149, 
			walk = 96965936208323,
		},
	},
	Paintgun = {
		basicAnimation = {
			idle = 134994892070328, 
			walk = 98366463075729,
		}
	},
	
	SandBasket = {
		basicAnimation = {
			idle = 99339441531347, 
			walk = 136011481992859,
		}
	},
	
	Megaphone = {
		basicAnimation = {
			idle = 80336095048971, 
		}
	},
	
	hand = {
		basicAnimation = {
			idle = 92300103187012, 
			walk = 91723268622405,
		}
	},
	
	bosstest = {
		basicAnimation = {
			idle = 110056137127137, 
		}
	},
	
	SandWorm = {
		basicAnimation = {
			idle = 82551011118743, 
			walk = 113030751374647,
		}
	},
	
	SandWormV2 = {
		basicAnimation = {
			idle = 105382745754555, 
		}
	},
	
	XYZAura = {
		basicAnimation = {
			idle = 99079263463798, 
			walk = 116176283227580,
		}
	},
	
	treeAura = {
		basicAnimation = {
			idle = 89870006429283, 
		}
	},
	
	Velvet = {
		basicAnimation = {
			idle = 122523185466708,
			walk = 75919395126491,
			jump = 133641093146774,
			fall = 127239301640306
		}
	},
	
	redmoonAura = {
		basicAnimation = {
			idle = 126939932722870,
		}
	},
	COTCM = {
		basicAnimation = {
			idle = 91065242358745
		}
		
	},
	RedMoonAura2222 = {
		basicAnimation = {
			idle = 112101789071231,
			walk = 133910610731434,
		}
	}
	
}


function AnimationsConfig:ResetAnimation(character)
	local animate = character:WaitForChild("Animate")
	-- Idle
	animate.idle.Animation1.AnimationId = "rbxassetid://180435571"
	animate.idle.Animation2.AnimationId = "rbxassetid://180435792"
	-- Walk
	animate.walk.WalkAnim.AnimationId = "rbxassetid://180426354"
	-- Run
	animate.run.RunAnim.AnimationId = "rbxassetid://180426354"
	-- Jump
	animate.jump.JumpAnim.AnimationId = "rbxassetid://125750702"
	-- Fall
	animate.fall.FallAnim.AnimationId = "rbxassetid://180436148"
	-- Climb
	animate.climb.ClimbAnim.AnimationId = "rbxassetid://180436334"
	-- Sit
	animate.sit.SitAnim.AnimationId = "rbxassetid://178130996"
	-- ToolNone (도구 들고 있는 상태)
	animate.toolnone.ToolNoneAnim.AnimationId = "rbxassetid://182393478"
end

return AnimationsConfig
