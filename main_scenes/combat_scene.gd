class_name PlayLoop
extends Node2D

### Controls game state/flow
### This is the core controller for the combat gameplay

const playable_unit_scene = preload("res://units/playable_unit.tscn")
const tree_scene = preload("uid://blmdyywmffl20")
const bonfire_scene = preload("uid://bivqb5bqkwvfl")
const health_space = preload("uid://cpl2nvc2valfa")
const thorns_space = preload("uid://cdnk21ui7wsbq")

@onready var units_node = $units
@onready var spaces_node = $spaces

@export var gd_pai_world_node: GdPAIWorldNode
@export var grid_system: GridNavigationSystem
@export var hud: HUD
@export var camera : Camera2D

func call_unit_placed(successful : bool):
	# HACK for some reason signal doesnt get caught the first time it's used
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
	SignalBus.game_over.connect(game_over)
	SignalBus.generate_tree.connect(generate_unit.bind(tree_scene))
	
	grid_system.debug_layer.hide()
	grid_system.init_layer.hide()
	camera.setup()
	
	for cell in grid_system.init_layer.get_used_cells():
		var atlas_coords = grid_system.init_layer.get_cell_atlas_coords(cell)
		match Globals.init_layer_meanings[atlas_coords]:
			"bonfire":
				place_bonfire(cell)
	
	for i in range(0, Globals.heal_count):
		generate_space(health_space)
	
	for i in range(0, Globals.thorn_count):
		generate_space(thorns_space)
	
	for i in range(0, Globals.tree_count):
		generate_unit(tree_scene)
	
	await SignalBus.deployment_finished
	
	active_unit = action_queue.pop_front()
	active_unit.is_active = true
	
	active_unit.agent.manually_start_plan()
	
	action_lock = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func action_done():
	if action_lock:
		return
	
	action_queue.push_back(active_unit)
	active_unit.is_active = false
	
	#await get_tree().create_timer(0.05).timeout
	
	bonfire.tick()
	
	# init new unit
	if action_queue.front() == null:
		action_queue.pop_front()
	
	active_unit = action_queue.pop_front()
	active_unit.is_active = true
	
	active_unit.agent.manually_start_plan()

func game_over():
	action_lock = true
	await get_tree().create_timer(1).timeout
	
	hud.game_over.text = "Bonfire stopped burning"
	
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
	unit.agent.goals.append(HealUpGoal.new())
	unit.agent.self_actions.append(WanderAction.new())
	
	Globals.register_unit(unit)
	
	unit_list.push_back(unit)
	action_queue.push_back(unit)
	
	call_unit_placed(true)

func place_bonfire(tilemap_position : Vector2i):
	bonfire = bonfire_scene.instantiate()
	units_node.add_child(bonfire)
	
	bonfire._data_init(tilemap_position)
	bonfire.global_position = grid_system._map_to_local(tilemap_position)
	
	Globals.register_unit(bonfire)

func generate_space(scene : PackedScene):
	var tilemap_position = grid_system.get_random_tile()
	
	while Globals.map_of_spaces.has(tilemap_position):
		tilemap_position = grid_system.get_random_tile()
	
	var space = scene.instantiate()
	units_node.add_child(space)
	
	space._data_init(tilemap_position)
	space.global_position = grid_system._map_to_local(tilemap_position)
	
	Globals.register_space(space)

func generate_unit(scene : PackedScene):
	var tilemap_position = grid_system.get_random_tile()
	
	while Globals.map_of_spaces.has(tilemap_position):
		tilemap_position = grid_system.get_random_tile()
	
	var unit = scene.instantiate()
	units_node.add_child(unit)
	
	unit._data_init(tilemap_position)
	unit.global_position = grid_system._map_to_local(tilemap_position)
	
	Globals.register_unit(unit)
#endregion
