extends Node2D

### Controls game state/flow
### This is the core controller for the combat gameplay

@export var camera : Camera2D

@export var grid_system: GridNavigationSystem
@export var unit_manager: UnitManager

var action_queue : Array[PlayableUnit]
var active_unit : PlayableUnit

var action_lock : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unit_manager.setup_units()
	await unit_manager.setup_done
	action_lock = false

# self documenting code amirite
func _unhandled_input(event: InputEvent) -> void:
	if not action_lock:
		if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT:
			
			var target_pos = grid_system._local_to_map(camera.get_global_mouse_position())
			
			match grid_system.availability_layer.is_actionable(target_pos):
				Globals.ActionType.Movement:
					move(target_pos)
				Globals.ActionType.Attack:
					attack(target_pos)
				Globals.ActionType.None:
					pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func move(move_to : Vector2i) -> void:
	action_lock = true
	
	unit_manager.move_unit(active_unit, move_to)
	await unit_manager.action_done
	
	if active_unit.movement_range <= 0:
		turn_done()
	
	action_lock = false

func attack(attack_to : Vector2i) -> void:
	action_lock = true
	
	var unit = unit_manager.map_of_units[attack_to]
	
	unit.health_component.receive_damage(active_unit.unit_res.damage)
	active_unit.nudge_attack(unit.global_position)
	await active_unit.attack_finished
	
	turn_done()
	
	action_lock = false

func turn_done() -> void:
	active_unit.turn_reset()
	
	action_queue.push_back(active_unit)
	active_unit = action_queue.pop_front()
	
	grid_system.set_availability(active_unit)
