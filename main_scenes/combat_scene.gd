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
var action_lock : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await hud.deployment_finished
	
	active_unit = action_queue.pop_front()
	active_unit.is_active = true
	
	Globals.action_initiated.connect(action_initialised)
	
	camera_to_active()
	unit_stat_display.display_unit(active_unit)
	unit_stat_display.show_me()
	
	action_lock = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.change_scene("res://main_scenes/menus/main_menu.tscn")

func move(move_to : Vector2i) -> void:
	unit_manager.move_unit(active_unit, move_to)

#func attack(attack_to : Vector2i) -> void:
	#var unit = unit_manager.map_of_units[attack_to]
	#
	#unit.health_component.receive_damage(active_unit.unit_res.damage)
	#active_unit.nudge_attack(unit.global_position)
	#await active_unit.attack_finished
	#
	#turn_done()

func action_initialised():
	camera_to_active()
	unit_stat_display.display_unit(active_unit)

func action_done():
	action_queue.push_back(active_unit)
	active_unit.is_active = false
	
	active_unit = action_queue.pop_front()
	active_unit.is_active = true

func camera_to_active():
	camera.position = active_unit.global_position
	#TODO movement range limits (3 to 12)
	var zoom = 1.2 - (float(clamp(active_unit.movement_range, 3, 12)) / 15)
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "zoom", Vector2(zoom, zoom), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func game_over():
	await get_tree().create_timer(1).timeout
	
	hud.game_over.text = "Done"
	
	var tween = get_tree().create_tween()
	tween.tween_property(hud.game_over, "modulate:a", 1, 1)
	await tween.finished
	await get_tree().create_timer(3).timeout
	
	SceneManager.change_scene("res://main_scenes/menus/main_menu.tscn")
