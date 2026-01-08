extends Node2D
class_name PlayableUnit

### All logic that is shared by all units
### Individual logic goes into resources

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

var held_item : Texture2D = null :
	set(value):
		agent.blackboard.set_property("holding_item", value != null)
		held_item_sprite.texture = value
		held_item = value

var is_active = false

var tilemap_position : Vector2i :
	set(value):
		agent.blackboard.set_property("tilemap_position", value)
		agent.blackboard.set_property("real_tilemap_position", value)
		tilemap_position = value
var movement_range : int

var action_time : float = 0.05

func _ready() -> void:
	assert(agent, "agent isn't set")
	
	health_component._max_hp = max_hp
	health_component.reset_hp()
	health_component.zero_hp.connect(die)
	
	base_texture.texture = sprite
	
	agent.blackboard.set_property("max_hp", health_component._max_hp)

#region Actions
func step(move_to : Vector2i) -> void:
	SignalBus.action_initiated.emit()
	
	await _step(move_to)
	
	if Globals.map_of_spaces.has(tilemap_position):
		Globals.map_of_spaces[tilemap_position].effect(self)
	
	SignalBus.action_done.emit()

func cut_tree(tree : TreeObject):
	SignalBus.action_initiated.emit()
	
	await _nudge_attack(tree.tilemap_position)
	
	tree.chopped()
	# waiting for tree exited, otherwise the AI could use it on the same frame
	# after it already got freed
	await tree.tree_exited
	
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
	
	health_component.receive_damage(15)
	
	var total_wood_count = Globals.world_blackboard.get_property("total_wood_count")
	Globals.world_blackboard.set_property("total_wood_count", total_wood_count - 1)
	
	SignalBus.action_done.emit()
#endregion

func die():
	Globals.unregister_unit(self)
	SignalBus.unit_killed.emit(self)
	
	self.queue_free()

func _sprite_flip(next_step : Vector2):
	if next_step.x > global_position.x:
		base_texture.flip_h = true
	elif next_step.x < global_position.x:
		base_texture.flip_h = false

# these have to be awaited
#region coroutines
func _step(target_position : Vector2i):
	#get path
	var path = Globals.grid_system.get_navigation_path(tilemap_position, target_position)
	path.pop_front()
	
	for item in path:
		Globals.grid_system.debug_layer.set_cell(item, 0, Globals.transparent_tile_coords["yellow"])
	
	#traverse
	Globals.relocate_unit(self, path[0])
	
	_sprite_flip(Globals.grid_system._map_to_local(path[0]))
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Globals.grid_system._map_to_local(path[0]), action_time)
	await tween.finished
	
	tilemap_position = path[0]

func _nudge_attack(target : Vector2):
	var return_pos = global_position
	var direction = (Globals.grid_system._map_to_local(target) - global_position).normalized()
	
	_sprite_flip(target)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", return_pos + direction * 50, action_time / 3)
	tween.tween_property(self, "global_position", return_pos, action_time / 3 * 2)
	await tween.finished
#endregion
