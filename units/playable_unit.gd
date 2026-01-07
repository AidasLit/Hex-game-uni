extends Node2D
class_name PlayableUnit

### All logic that is shared by all units
### Individual logic goes into resources

#enum States{
	#IDLE,
	#MOVEMENT,
	#NUDGE
#}

@onready var health_component: HealthComponent = $HealthComponent
@onready var base_texture: Sprite2D = $Sprite2D
@onready var held_item_sprite: Sprite2D = $HeldItem

## Reference to the GdPAI agent.
@export var agent: GdPAIAgent

@export var id : int
@export var sprite : CompressedTexture2D
@export var my_name : String
@export var max_hp : int
@export var damage : int
@export var max_movement_range : int

#var state : States = States.IDLE

var held_item : Texture2D = null :
	set(value):
		agent.blackboard.set_property("holding_item", value != null)
		held_item_sprite.texture = value
		held_item = value

var is_active = false

#signal state_changed

var tilemap_position : Vector2i :
	set(value):
		agent.blackboard.set_property("tilemap_position", value)
		tilemap_position = value
var movement_range : int

func _ready() -> void:
	assert(agent, "agent isn't set")
	
	#health_component.zero_hp.connect(_on_zero_hp)
	health_component._max_hp = max_hp
	health_component.reset_hp()
	
	base_texture.texture = sprite
	
	agent.blackboard.set_property("max_hp", health_component._max_hp)

#func change_state(new_state : States) -> void:
	#if (state == new_state):
		#print("old and new states are identical")
		#return
	#
	#var old_state = state
	#
	## State exit logic
	#match old_state:
		#States.IDLE:
			#pass
		#_:
			#pass
	#
	## State enter logic
	#match new_state:
		#States.IDLE:
			#var tween = get_tree().create_tween()
			#tween.tween_property(self, "scale", Vector2.ONE, 0.3)
		#_:
			#var tween = get_tree().create_tween()
			#tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	#
	#state_changed.emit()

func move(move_to : Vector2i, stop_next_to : bool) -> void:
	SignalBus.action_initiated.emit()
	
	#get path
	var path = Globals.grid_system.get_navigation_path(tilemap_position, move_to, stop_next_to)
	path.pop_front()
	
	#traverse
	await _travel_path(Globals.grid_system.path_to_global_path(path))
	
	SignalBus.action_done.emit()

func cut_tree(tree : TreeObject):
	SignalBus.action_initiated.emit()
	
	await _nudge_attack(tree.tilemap_position)
	
	tree.chopped()
	# waiting for tree exited, otherwise the AI could use it on the same frame
	# after it already got freed
	await tree.tree_exited
	#await get_tree().process_frame
	
	SignalBus.action_done.emit()

func take_wood(wood : WoodObject):
	SignalBus.action_initiated.emit()
	
	await _nudge_attack(wood.tilemap_position)
	
	held_item = wood.sprite.texture
	wood.taken()
	await wood.tree_exited
	
	SignalBus.action_done.emit()

func throw_wood(bonfire : BonfireObject):
	assert(held_item != null, "No wood held when throwing it")
	SignalBus.action_initiated.emit()
	
	await _nudge_attack(bonfire.tilemap_position)
	
	held_item = null
	bonfire.feed()
	
	SignalBus.action_done.emit()

#func _on_zero_hp() -> void:
	#SignalBus.unit_killed.emit(self)

func _sprite_flip(next_step : Vector2):
	if next_step.x > global_position.x:
		base_texture.flip_h = true
	elif next_step.x < global_position.x:
		base_texture.flip_h = false

# these have to be awaited
#region coroutines
func _travel_path(path : Array[Vector2]):
	for step : Vector2 in path:
		#Globals.grid_system.set_tile_disabled(tilemap_position, false)
		#Globals.grid_system.set_tile_disabled(Globals.grid_system._local_to_map(step), true)
		Globals.relocate_unit(self, Globals.grid_system._local_to_map(step))
		
		_sprite_flip(step)
		
		# await needs to happen inside this loop
		# if it's in a seperate function, the looped functions will be executed in "parallel", which is not what we want
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", step, 0.2)
		await tween.finished
		
		await get_tree().create_timer(0.05).timeout
		
		tilemap_position = Globals.grid_system._local_to_map(step)
		
		#SignalBus.action_done.emit()
		#return

func _nudge_attack(target : Vector2):
	var return_pos = global_position
	var direction = (Globals.grid_system._map_to_local(target) - global_position).normalized()
	
	_sprite_flip(target)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", return_pos + direction * 50, 0.1)
	tween.tween_property(self, "global_position", return_pos, 0.2)
	await tween.finished
#endregion
