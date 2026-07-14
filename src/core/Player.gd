class_name Player
extends RefCounted

enum Team {
	RED,
	BLUE
}

enum Status {
	ACTIVE,
	ELIMINATED
}

enum RayOrigin {
	CENTER,
	LEFT,
	RIGHT
}

var id: int = 0
var number: int = 0
var team: Team = Team.RED
var status: Status = Status.ACTIVE

var position_metric: Vector2 = Vector2.ZERO
var rotation: float = 0.0
var ray_origin: RayOrigin = RayOrigin.CENTER

var fire_enabled: bool = true
var visible: bool = true

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"number": number,
		"team": team,
		"status": status,
		"x": position_metric.x,
		"y": position_metric.y,
		"rotation": rotation,
		"ray_origin": ray_origin,
		"fire_enabled": fire_enabled,
		"visible": visible
	}

func from_dictionary(data: Dictionary) -> void:
	id = data.get("id", 0)
	number = data.get("number", 0)
	team = data.get("team", Team.RED)
	status = data.get("status", Status.ACTIVE)
	position_metric = Vector2(data.get("x", 0.0), data.get("y", 0.0))
	rotation = data.get("rotation", 0.0)
	ray_origin = data.get("ray_origin", RayOrigin.CENTER)
	fire_enabled = data.get("fire_enabled", true)
	visible = data.get("visible", true)

func get_screen_position(field: Field) -> Vector2:
	if field and field.calibrated:
		return field.field_to_screen(position_metric)
	return position_metric * 20.0

func set_from_screen(screen_pos: Vector2, field: Field) -> void:
	if field and field.calibrated:
		position_metric = field.screen_to_field(screen_pos)
	else:
		position_metric = screen_pos

func get_direction() -> Vector2:
	return Vector2(1, 0).rotated(rotation)

func set_rotation_degrees(deg: float) -> void:
	rotation = deg_to_rad(deg)

func get_rotation_degrees() -> float:
	return rad_to_deg(rotation)

func get_ray_offset(radius_px: float) -> Vector2:
	match ray_origin:
		RayOrigin.LEFT:
			return Vector2(0, -radius_px * 0.95)  # Почти до края!
		RayOrigin.RIGHT:
			return Vector2(0, radius_px * 0.95)   # Почти до края!
		_:
			return Vector2.ZERO

# Переключение только между LEFT и RIGHT (без CENTER!)
func toggle_ray_origin() -> void:
	match ray_origin:
		RayOrigin.LEFT:
			ray_origin = RayOrigin.RIGHT
		RayOrigin.RIGHT:
			ray_origin = RayOrigin.LEFT
		_:
			ray_origin = RayOrigin.LEFT

# Вернуть в центр (только двойным кликом)
func set_ray_origin_center() -> void:
	ray_origin = RayOrigin.CENTER

func get_ray_origin_name() -> String:
	match ray_origin:
		RayOrigin.LEFT:
			return "Лево"
		RayOrigin.RIGHT:
			return "Право"
		_:
			return "Центр"
