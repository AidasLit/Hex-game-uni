extends Node2D

### Controls game state/flow
### This is the core controller for the combat gameplay

@export var grid_system: GridNavigationSystem

var action_queue : Array[PlayableUnit]
var active_unit : PlayableUnit

var action_lock : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_units()

# self documenting code amirite
func _input(event: InputEvent) -> void:
	if not action_lock:
		if event is InputEventMouseButton:
			if event.pressed:
				# TODO there's a bug somewhere allowing an unit to move twice.
				# I suspect it's some sort of a race condition, but needs more investigation
				# UPDATE 1: found a flaw in the logic and fixed it, but can't confirm a bugfix
				#  that said I have not had it happen once since
				move_to_position(event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _setup_units() -> void:
	var i = 0
	for unit : PlayableUnit in get_tree().get_nodes_in_group("unit"):
		var start_location = grid_system._map_to_local(Vector2i(grid_system.astargrid.get_point_position(i)))
		
		unit.unit_owner = Globals.UnitOwner.Player
		unit.goto_location(start_location)
		action_queue.push_back(unit)
		
		grid_system.set_unit_on_tile(start_location, true)
		i += 12
	
	active_unit = action_queue.pop_front()
	await active_unit.done_moving
	grid_system.set_availability(active_unit)

func move_to_position(move_to : Vector2) -> void:
	if not grid_system.availability_layer.is_available(grid_system._local_to_map(move_to)):
		return
	
	action_lock = true
	var path = grid_system.get_navigation_path(active_unit.global_position, move_to)
	
	grid_system.set_unit_on_tile(active_unit.global_position, false)
	active_unit.travel_path(path)
	
	await active_unit.done_moving
	grid_system.set_unit_on_tile(active_unit.global_position, true)
	
	turn_done()
	
	action_lock = false

func turn_done() -> void:
	action_queue.push_back(active_unit)
	active_unit = action_queue.pop_front()
	
	grid_system.set_availability(active_unit)
