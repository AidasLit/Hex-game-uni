extends Resource
class_name PlayableUnitRes

@export var id : int
@export var sprite : CompressedTexture2D
@export var name : String
@export var max_hp : int
@export var damage : int
@export var movement_range : int

func print_name() -> void:
	print(name)
