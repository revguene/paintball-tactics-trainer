class_name BunkerType

enum Type {
	GIANT_BLOCK,
	MINI_BLOCK,
	GIANT_WING,
	MINI_WING,
	PLUS,
	MAYAN_TEMPLE,
	TEMPLE,
	CAN,
	PILLAR,
	CAKE,
	CAKE_TAIL,
	DORITO_MEDIUM,
	DORITO_SMALL,
	SNAKE_BEAM,
	SNAKE_SMALL,
	MINI_M,
	BRICK
}

static func get_display_name(type: Type) -> String:
	match type:
		Type.GIANT_BLOCK: return "Giant Block"
		Type.MINI_BLOCK: return "Mini Block"
		Type.GIANT_WING: return "Giant Wing"
		Type.MINI_WING: return "Mini Wing"
		Type.PLUS: return "Plus"
		Type.MAYAN_TEMPLE: return "Mayan Temple"
		Type.TEMPLE: return "Temple"
		Type.CAN: return "Can"
		Type.PILLAR: return "Pillar"
		Type.CAKE: return "Cake"
		Type.CAKE_TAIL: return "Cake Tail"
		Type.DORITO_MEDIUM: return "Dorito Medium"
		Type.DORITO_SMALL: return "Dorito Small"
		Type.SNAKE_BEAM: return "Snake Beam"
		Type.SNAKE_SMALL: return "Snake Small"
		Type.MINI_M: return "Mini M"
		Type.BRICK: return "Brick"
		_: return "Unknown"

static func get_all_types() -> Array:
	return Type.values()
