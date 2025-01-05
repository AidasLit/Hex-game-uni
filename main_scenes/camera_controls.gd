extends Camera2D

var SPEED = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta):
	zoom()
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if input_direction:
		position += input_direction * SPEED
		
		var limit_offset = get_viewport().get_visible_rect().size / 2
		limit_offset = limit_offset / get_zoom()
		var limit_from = Vector2(limit_left + limit_offset.x, limit_top + limit_offset.y)
		var limit_to = Vector2(limit_right - limit_offset.x, limit_bottom - limit_offset.y)
		position = position.clamp(limit_from, limit_to)

func zoom():
	var new_zoom = get_zoom()
	
	if Input.is_action_just_released('wheel_down'):
		new_zoom -= Vector2(0.05, 0.05)
	if Input.is_action_just_released('wheel_up'):
		new_zoom += Vector2(0.05, 0.05)
	
	new_zoom = new_zoom.clamp(Vector2(0.4, 0.4), Vector2(1, 1))
	SPEED = 10 / new_zoom.x
	set_zoom(new_zoom)
