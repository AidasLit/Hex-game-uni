extends Camera2D

var SPEED = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta):
	update_zoom()
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if input_direction:
		position += input_direction * SPEED
		
		var limit_offset = get_viewport().get_visible_rect().size / 2
		limit_offset = limit_offset / get_zoom()
		var limit_from = Vector2(limit_left + limit_offset.x, limit_top + limit_offset.y)
		var limit_to = Vector2(limit_right - limit_offset.x, limit_bottom - limit_offset.y)
		position = position.clamp(limit_from, limit_to)

func setup():
	var dimensions = Globals.grid_system.dimensions
	var horizontal_start = dimensions.x.x
	var horizontal_end = dimensions.x.y
	var vertical_start = dimensions.y.x
	var vertical_end = dimensions.y.y
	var start_pos = Vector2(horizontal_start, vertical_start)
	var end_pos = Vector2(horizontal_end, vertical_end)
	
	limit_left = Globals.grid_system._map_to_local(Vector2i(start_pos)).x as int
	limit_top = Globals.grid_system._map_to_local(Vector2i(start_pos)).y as int
	
	limit_right = Globals.grid_system._map_to_local(Vector2i(end_pos)).x as int
	limit_bottom = Globals.grid_system._map_to_local(Vector2i(end_pos)).y as int
	
	position.x = limit_left + (limit_right - limit_left) * 0.5
	position.y = limit_top + (limit_bottom - limit_top) * 0.5

func update_zoom():
	var new_zoom = get_zoom()
	
	if Input.is_action_just_released('wheel_down'):
		new_zoom -= Vector2(0.1, 0.1)
	if Input.is_action_just_released('wheel_up'):
		new_zoom += Vector2(0.1, 0.1)
	
	var max_zoom = (get_viewport().size as Vector2) / Vector2(limit_right - limit_left, limit_bottom - limit_top)
	new_zoom = new_zoom.clamp(Vector2.ONE * max(max_zoom.x, max_zoom.y), Vector2.ONE * 2)
	SPEED = 15 / new_zoom.x
	set_zoom(new_zoom)
