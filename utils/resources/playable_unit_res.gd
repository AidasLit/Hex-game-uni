extends Resource
class_name PlayableUnitRes

@export var sprite : CompressedTexture2D
@export var name : String
@export var max_hp : int
@export var damage : int
@export var movement_range : int

@export var _movement : GDScript
@export var _attack : GDScript

var movement
var attack

var unit : PlayableUnit

func setup(unit):
	resource_local_to_scene = true
	
	movement = _movement.new()
	movement.unit = unit

func print_name() -> void:
	print(name)
