class_name BunkerLibrary
extends RefCounted

const DATA := {
	BunkerType.Type.GIANT_BLOCK: {
		"name": "Giant Block",
		"shape": "rect",
		"width": 3.30,
		"height": 2.00
	},
	BunkerType.Type.MINI_BLOCK: {
		"name": "Mini Block",
		"shape": "rect",
		"width": 1.40,
		"height": 1.10
	},
	BunkerType.Type.GIANT_WING: {
		"name": "Giant Wing",
		"shape": "wing",
		"width": 3.00,
		"height": 2.00
	},
	BunkerType.Type.MINI_WING: {
		"name": "Mini Wing",
		"shape": "wing",
		"width": 2.20,
		"height": 1.10
	},
	BunkerType.Type.PLUS: {
		"name": "Plus",
		"shape": "plus",
		"width": 2.10,
		"height": 2.10
	},
	BunkerType.Type.MAYAN_TEMPLE: {
		"name": "Mayan Temple",
		"shape": "square",
		"width": 1.65,
		"height": 1.65
	},
	BunkerType.Type.TEMPLE: {
		"name": "Temple",
		"shape": "square",
		"width": 1.50,
		"height": 1.50
	},
	BunkerType.Type.CAN: {
		"name": "Can",
		"shape": "circle",
		"radius": 0.65
	},
	BunkerType.Type.PILLAR: {
		"name": "Pillar",
		"shape": "circle",
		"radius": 0.50
	},
	BunkerType.Type.CAKE: {
		"name": "Cake",
		"shape": "triangle",
		"size": 1.20
	},
	BunkerType.Type.CAKE_TAIL: {
		"name": "Cake Tail",
		"shape": "rect",
		"width": 1.50,
		"height": 1.00
	},
	BunkerType.Type.DORITO_SMALL: {
		"name": "Dorito Small",
		"shape": "triangle",
		"size": 1.90
	},
	BunkerType.Type.DORITO_MEDIUM: {
		"name": "Dorito Medium",
		"shape": "triangle",
		"size": 2.40
	},
	BunkerType.Type.SNAKE_BEAM: {
		"name": "Snake Beam",
		"shape": "rect",
		"width": 3.00,
		"height": 0.50
	},
	BunkerType.Type.SNAKE_SMALL: {
		"name": "Snake Small",
		"shape": "rect",
		"width": 2.80,
		"height": 0.60
	},
	BunkerType.Type.MINI_M: {
		"name": "Mini M",
		"shape": "rect",
		"width": 1.00,
		"height": 2.80
	},
	BunkerType.Type.BRICK: {
		"name": "Brick",
		"shape": "rect",
		"width": 1.90,
		"height": 1.00
	}
}

static func get_info(type: int) -> Dictionary:
	return DATA.get(type, {})
