class_name TreeObject
extends Node2D

@export var wood_scene: PackedScene
@onready var tree_object_data: TreeObjectData = $TreeObjectData

var tilemap_position: Vector2i

func _init() -> void:
	var tree_count = Globals.world_blackboard.get_property("tree_count")
	Globals.world_blackboard.set_property("tree_count", tree_count + 1)

func _data_init(_tilemap_position : Vector2i) -> void:
	tilemap_position = _tilemap_position
	tree_object_data.tilemap_position = _tilemap_position

func chopped():
	var tree_count = Globals.world_blackboard.get_property("tree_count")
	Globals.world_blackboard.set_property("tree_count", tree_count - 1)
	
	var wood_obj = wood_scene.instantiate()
	Globals.play_loop.units_node.add_child(wood_obj)
	
	wood_obj._data_init(tilemap_position)
	wood_obj.global_position = global_position
	
	Globals.unregister_unit(self)
	Globals.register_unit(wood_obj)
	
	SignalBus.unit_killed.emit(self)
	SignalBus.generate_tree.emit()
	self.queue_free()
