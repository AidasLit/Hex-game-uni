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
			# TODO needs to be refactored into something like:
			# match availability_layer.is_actionable(unit):
			#     globals.ActionType.Movement:
			#         move_to_position(event.position)
			#     globals.ActionType.None:
			#         throw_error()
			if event.pressed:
				if grid_system.availability_layer.is_movable(grid_system._local_to_map(event.position)):
					move_to_position(event.position)
				elif grid_system.availability_layer.is_attackable(grid_system._local_to_map(event.position)):
					attack_to_position(event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _setup_units() -> void:
	var RNG = RandomNumberGenerator.new()
	var i = RNG.randi_range(0, grid_system.astargrid.get_point_count()/3)
	for unit : PlayableUnit in get_tree().get_nodes_in_group("unit"):
		var start_location = grid_system._map_to_local(Vector2i(grid_system.astargrid.get_point_position(i)))
		
		unit.unit_owner = Globals.UnitOwner.Rogue
		unit.goto_location(start_location)
		unit.tilemap_position = Vector2i(grid_system.astargrid.get_point_position(i))
		unit.kill_me.connect(kill_unit)
		action_queue.push_back(unit)
		
		grid_system.set_unit_on_tile(unit.tilemap_position, true)
		i += RNG.randi_range(1, grid_system.astargrid.get_point_count()/3 - 1)
	
	active_unit = action_queue.pop_front()
	await active_unit.done_moving
	grid_system.set_availability(active_unit)

func move_to_position(move_to : Vector2) -> void:
	action_lock = true
	
	#if not grid_system.availability_layer.is_movable(grid_system._local_to_map(move_to)):
		#action_lock = false
		#return
	
	var path = grid_system.get_navigation_path(active_unit.tilemap_position, grid_system._local_to_map(move_to))
	path.pop_front()
	
	grid_system.set_unit_on_tile(active_unit.tilemap_position, false)
	active_unit.travel_path(grid_system.path_to_global_path(path))
	print(path)
	active_unit.tilemap_position = path.back()
	
	await active_unit.done_moving
	grid_system.set_unit_on_tile(active_unit.tilemap_position, true)
	
	if path.size() < active_unit.movement_range:
		active_unit.movement_range -= path.size()
		turn_done(true)
	else:
		turn_done(false)
	
	action_lock = false

func attack_to_position(attack_to : Vector2) -> void:
	action_lock = true
	var attack_tile_pos = grid_system._local_to_map(attack_to)
	
	for unit : PlayableUnit in get_tree().get_nodes_in_group("unit"):
		if unit.tilemap_position == attack_tile_pos:
			unit.health_component.receive_damage(active_unit.damage)
			active_unit.nudge_attack(unit.global_position)
			await active_unit.attack_finished
	
	turn_done(false)
	
	action_lock = false

func turn_done(to_continue : bool) -> void:
	if to_continue:
		pass
	else:
		active_unit.turn_reset()
		
		action_queue.push_back(active_unit)
		active_unit = action_queue.pop_front()
	
	grid_system.set_availability(active_unit)

func kill_unit(unit_to_kill):
	grid_system.set_unit_on_tile(unit_to_kill.tilemap_position, false)
	grid_system.set_availability(active_unit)
	
	action_queue.erase(unit_to_kill)
	unit_to_kill.queue_free()
