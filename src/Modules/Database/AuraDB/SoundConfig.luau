export type SoundData = {
	SoundID: number,
	Volume: number,
	Distance: number,
}

local SoundConfig: { [string]: SoundData } = {
	["APOSTOLOS"] = {
		SoundID = 105646528027261,
		Volume = 5,
		Distance = 1000,
	},
	["Astraios"] = {
		SoundID = 0,
		Volume = 5,
		Distance = 3000,
	},
	["ASTRAIOS_V2"] = {
		SoundID = 131014725727281,
		Volume = 10,
		Distance = 3000,
	},
	["ASTRAIOS_V2_1"] = {
		SoundID = 109087785955404,
		Volume = 10,
		Distance = 3000,
	},
	["GARGANTUA"] = {
		SoundID = 140326079604299,
		Volume = 5,
		Distance = 1000,
	},
	["Warlock"] = {
		SoundID = 1837463487,
		Volume = 5,
		Distance = 1000,
	},
	["Elude"] = {
		SoundID = 81243632584798,
		Volume = 5,
		Distance = 1000,
	},
	["PROLOGUE_rework"] = {
		SoundID = 134011320411309,
		Volume = 10,
		Distance = 1000,
	},
	["PROLOGUE"] = {
		SoundID = 126525264257848,
		Volume = 5,
		Distance = 1000,
	},
	["SandWormV2"] = {
		SoundID = 124290892075068,
		Volume = 5,
		Distance = 1000,
	},
	["COTCM"] = {
		SoundID = 110746779413632,
		Volume = 5,
		Distance = 1000,
	},
	["redmoonAura"] = {
		SoundID = 116326228761082,
		Volume = 5,
		Distance = 1000,
	},
}

return SoundConfig
