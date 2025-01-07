extends Node2D

### Controls game state/flow
### This is the core controller for the combat gameplay

@export var camera : Camera2D

@export var grid_system: GridNavigationSystem
@export var unit_manager: UnitManager
@export var hud: HUD
@export var unit_stat_display: StatsDisplay

var unit_list : Array[PlayableUnit]
var action_queue : Array[PlayableUnit]
var active_unit : PlayableUnit

var team_lists : Dictionary = {
	Globals.UnitOwner.Player : [],
	Globals.UnitOwner.Enemy : [],
}

var action_lock : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unit_manager.setup_units()
	await unit_manager.setup_done
	
	if await update_queue():
		active_unit = action_queue.pop_front()
		grid_system.set_availability(active_unit)
		camera_to_active()
		hud.set_team_label(active_unit.unit_owner)
		unit_stat_display.display_unit(active_unit)
		unit_stat_display.show_me()
		
		var tween = get_tree().create_tween()
		tween.tween_property(active_unit, "scale", Vector2(1.5, 1.5), 0.3)
	
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
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.change_scene("res://main_scenes/menus/main_menu.tscn")

func move(move_to : Vector2i) -> void:
	action_lock = true
	
	unit_manager.move_unit(active_unit, move_to)
	await unit_manager.action_done
	
	if active_unit.movement_range <= 0:
		turn_done()
	else:
		camera_to_active()
	action_lock = false

func attack(attack_to : Vector2i) -> void:
	action_lock = true
	
	var unit = unit_manager.map_of_units[attack_to]
	
	unit.health_component.receive_damage(active_unit.unit_res.damage)
	active_unit.nudge_attack(unit.global_position)
	await active_unit.attack_finished
	
	turn_done()
	
	action_lock = false
	
	if team_lists[Globals.UnitOwner.Player].is_empty():
		game_over(Globals.UnitOwner.Enemy)
	if team_lists[Globals.UnitOwner.Enemy].is_empty():
		game_over(Globals.UnitOwner.Player)

func turn_done() -> void:
	action_lock = true
	active_unit.turn_reset()
	
	#action_queue.push_back(active_unit)
	if await update_queue():
		active_unit = action_queue.pop_front()
		grid_system.set_availability(active_unit)
		camera_to_active()
		hud.set_team_label(active_unit.unit_owner)
		unit_stat_display.display_unit(active_unit)
		
		var tween = get_tree().create_tween()
		tween.tween_property(active_unit, "scale", Vector2(1.5, 1.5), 0.3)
	
	action_lock = false

func camera_to_active():
	camera.position = active_unit.global_position
	#TODO movement range limits (3 to 12)
	var zoom = 1.2 - (float(clamp(active_unit.unit_res.movement_range, 3, 12)) / 15)
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "zoom", Vector2(zoom, zoom), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


func update_queue():
	if action_queue:
		return true
	else:
		#await get_tree().physics_frame
		if await update_speed_counters():
			return true
		else:
			return await update_queue()

func update_speed_counters():
	var to_return = false
	for unit : PlayableUnit in unit_list:
		unit.unit_res.speed_counter = unit.unit_res.speed_counter - 1
		
		if unit.unit_res.speed_counter == 0:
			action_queue.append(unit)
			to_return = true
	
	return to_return

func game_over(winner : Globals.UnitOwner):
	action_lock = true
	await get_tree().create_timer(1).timeout
	
	hud.game_over.label_settings.outline_color = Globals.team_colors[winner]
	match winner:
		Globals.UnitOwner.Player:
			hud.game_over.text= "Winner - Player 1"
		Globals.UnitOwner.Enemy:
			hud.game_over.text = "Winner - Player 2"
		_:
			hud.game_over.text = "error"
	
	var tween = get_tree().create_tween()
	tween.tween_property(hud.game_over, "modulate:a", 1, 1)
	await tween.finished
	await get_tree().create_timer(3).timeout
	
	SceneManager.change_scene("res://main_scenes/menus/main_menu.tscn")
