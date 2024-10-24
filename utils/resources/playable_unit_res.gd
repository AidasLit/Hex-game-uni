extends Resource
class_name PlayableUnitRes

@export var sprite : CompressedTexture2D
@export var name : String
@export var max_hp : int
@export var damage : int

@export var movement : UnitMovement
@export var attack : UnitAttack

var unit : PlayableUnit

func setup(unit):
	resource_local_to_scene = true
	
	movement.unit = unit

func print_name() -> void:
	print(name)
