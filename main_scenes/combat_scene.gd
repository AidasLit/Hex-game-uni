class_name PlayLoop
extends Node2D

### Controls game state/flow
### This is the core controller for the combat gameplay

const playable_unit_scene = preload("res://units/playable_unit.tscn")
const tree_scene = preload("uid://blmdyywmffl20")
const bonfire_scene = preload("uid://bivqb5bqkwvfl")

@onready var units_node = $units

@export var gd_pai_world_node: GdPAIWorldNode
@export var grid_system: GridNavigationSystem
@export var hud: HUD
@export var camera : Camera2D

func call_unit_placed(successful : bool):
	# BUG for some reason signal doesnt get caught the first time it's used
	# unless it's being called in a deferred mode. lookup more of
	# https://www.reddit.com/r/godot/comments/p6jm0s/are_signals_called_inline_or_are_they_deferred_in/
	#unit_placed.emit(successful)
	(func(): SignalBus.unit_placed.emit(successful)).call_deferred()

var unit_list : Array[PlayableUnit]
var action_queue : Array[PlayableUnit]

var active_unit : PlayableUnit
var action_lock : bool = true

var bonfire : BonfireObject = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.play_loop = self
	Globals.grid_system = grid_system
	Globals.hud = hud
	Globals.camera = camera
	Globals.world_blackboard = gd_pai_world_node.world_state
	
	SignalBus.action_done.connect(action_done)
	SignalBus.action_initiated.connect(func():
		active_unit.is_active = false
	)
	SignalBus.game_over.connect(func():
		action_lock = true
		SceneManager.change_scene("res://main_scenes/menus/main_menu.tscn")
	)
	
	camera.setup()
	
	place_bonfire()
	
	generate_unit(tree_scene)
	generate_unit(tree_scene)
	generate_unit(tree_scene)
	
	await SignalBus.deployment_finished
	
	active_unit = action_queue.pop_front()
	active_unit.is_active = true
	
	active_unit.agent.manually_start_plan()
	
	action_lock = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.change_scene("res://main_scenes/menus/main_menu.tscn")

func action_done():
	if action_lock:
		return
	
	# handle old unit
	action_queue.push_back(active_unit)
	active_unit.is_active = false
	
	#await get_tree().create_timer(0.05).timeout
	
	bonfire.tick()
	
	# init new unit
	active_unit = action_queue.pop_front()
	active_unit.is_active = true
	
	active_unit.agent.manually_start_plan()

func game_over():
	await get_tree().create_timer(1).timeout
	
	hud.game_over.text = "Done"
	
	var tween = get_tree().create_tween()
	tween.tween_property(hud.game_over, "modulate:a", 1, 1)
	await tween.finished
	await get_tree().create_timer(3).timeout
	
	SceneManager.change_scene("res://main_scenes/menus/main_menu.tscn")


#region Unit Management
func try_place_unit(at_position : Vector2):
	if not grid_system.is_global_pos_valid(at_position):
		call_unit_placed(false)
		return
	
	var unit : PlayableUnit = playable_unit_scene.instantiate()
	units_node.add_child(unit)
	
	unit.tilemap_position = Globals.grid_system._local_to_map(at_position)
	unit.global_position = Globals.grid_system._map_to_local(unit.tilemap_position)
	
	unit.agent.world_node = GdPAIUTILS.get_child_of_type(get_tree().root, GdPAIWorldNode)
	unit.agent.goals.append(WanderGoal.new())
	unit.agent.goals.append(MaintainFireGoal.new())
	unit.agent.self_actions.append(WanderAction.new())
	
	Globals.register_unit(unit)
	
	unit_list.push_back(unit)
	action_queue.push_back(unit)
	
	call_unit_placed(true)

func generate_unit(scene : PackedScene):
	var tilemap_position = grid_system.get_random_tile()
	
	var unit = scene.instantiate()
	units_node.add_child(unit)
	
	unit._data_init(tilemap_position)
	unit.global_position = grid_system._map_to_local(tilemap_position)
	
	Globals.register_unit(unit)

func place_bonfire():
	var tilemap_position = Vector2i(10, 5)
	
	bonfire = bonfire_scene.instantiate()
	units_node.add_child(bonfire)
	
	bonfire._data_init(tilemap_position)
	bonfire.global_position = grid_system._map_to_local(tilemap_position)
	
	Globals.register_unit(bonfire)
#endregion
