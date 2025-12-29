class_name PlayLoop
extends Node2D

### Controls game state/flow
### This is the core controller for the combat gameplay

@export var camera : Camera2D

@export var gd_pai_world_node: GdPAIWorldNode
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
	Globals.play_loop = self
	Globals.grid_system = grid_system
	Globals.unit_manager = unit_manager
	Globals.hud = hud
	Globals.camera = camera
	Globals.world_blackboard = gd_pai_world_node.world_state
	
	SignalBus.action_initiated.connect(action_initialised)
	SignalBus.action_done.connect(action_done)
	
	camera.setup()
	
	#unit_manager.generate_tree()
	
	await SignalBus.deployment_finished
	
	active_unit = action_queue.pop_front()
	active_unit.is_active = true
	
	camera.to_active()
	
	unit_stat_display.display_unit(active_unit)
	unit_stat_display.show_me()
	
	action_lock = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.change_scene("res://main_scenes/menus/main_menu.tscn")

func move(move_to : Vector2i, stop_next_to : bool) -> void:
	unit_manager.move_unit(active_unit, move_to, stop_next_to)

func cut_tree(target_position : Vector2i):
	unit_manager.chop_tree(active_unit, target_position)

#func attack(attack_to : Vector2i) -> void:
	#var unit = unit_manager.map_of_units[attack_to]
	#
	#unit.health_component.receive_damage(active_unit.unit_res.damage)
	#active_unit.nudge_attack(unit.global_position)
	#await active_unit.attack_finished
	#
	#turn_done()

func action_initialised():
	unit_stat_display.display_unit(active_unit)

func action_done():
	action_queue.push_back(active_unit)
	active_unit.is_active = false
	
	active_unit = action_queue.pop_front()
	active_unit.is_active = true
	
	camera.to_active()

func game_over():
	await get_tree().create_timer(1).timeout
	
	hud.game_over.text = "Done"
	
	var tween = get_tree().create_tween()
	tween.tween_property(hud.game_over, "modulate:a", 1, 1)
	await tween.finished
	await get_tree().create_timer(3).timeout
	
	SceneManager.change_scene("res://main_scenes/menus/main_menu.tscn")
