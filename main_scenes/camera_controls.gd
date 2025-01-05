extends Camera2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if input_direction:
		print(input_direction)
		translate(input_direction * 10)
