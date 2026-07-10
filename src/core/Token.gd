class_name Token
extends Entity

## Токен — базовый элемент (игрок, судья, камера, маркер)

enum TokenType {
	PLAYER,
	REFEREE,
	CAMERA,
	MARKER,
	DIRECTION
}

var token_type: TokenType = TokenType.PLAYER

# Для игрока
var team: String = ""  # red/blue
var status: String = "active"  # active/eliminated
var role: String = ""  # front/mid/back

# Для камеры
var view_direction: Vector2 = Vector2.ZERO
var view_angle: float = 90.0

func to_dict() -> Dictionary:
	var data = super()
	data["token_type"] = token_type
	data["team"] = team
	data["status"] = status
	data["role"] = role
	data["view_direction"] = [view_direction.x, view_direction.y]
	data["view_angle"] = view_angle
	return data

func from_dict(data: Dictionary) -> void:
	super(data)
	token_type = data.get("token_type", TokenType.PLAYER)
	team = data.get("team", "")
	status = data.get("status", "active")
	role = data.get("role", "")
	var dir = data.get("view_direction", [0, 0])
	view_direction = Vector2(dir[0], dir[1])
	view_angle = data.get("view_angle", 90.0)
