extends Node2D

### Controls game state/flow
### This is the core controller for the combat gameplay

@export var grid_system: GridNavigationSystem

var active_unit : PlayableUnit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_units()

# self documenting code amirite
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# local_to_map translates our mouse click position into a tilemap position
			var target_cell : Vector2i = grid_system.local_to_map(event.position)
			
			var path = grid_system.get_navigation_path(grid_system.local_to_map(active_unit.global_position), target_cell)
			
			if not path.is_empty():
				active_unit.travel_path(path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _setup_units():
	active_unit = $units/solider
	active_unit.goto_location(grid_system.map_to_local(Vector2i(0, 0)))
