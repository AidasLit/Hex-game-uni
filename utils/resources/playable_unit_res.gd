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

func setup(unit):
	movement = _movement.new()
	movement.unit = unit

func print_name() -> void:
	print(name)
