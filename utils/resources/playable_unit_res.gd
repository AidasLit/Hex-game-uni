extends Resource
class_name PlayableUnitRes

@export var id : int
@export var sprite : CompressedTexture2D
@export var name : String
@export var max_hp : int
@export var damage : int
@export var slowness : int
@export var movement_range : int

@export var _movement : GDScript
@export var _attack : GDScript

var movement
var attack
var speed_label : Label
var speed_counter : int :
	set(value):
		speed_counter = value
		update_speed_label(value)

func setup(unit):
	movement = _movement.new()
	movement.unit = unit
	
	speed_label = unit.speed_label
	speed_counter = slowness

func print_name() -> void:
	print(name)

func update_speed_label(value : int):
	speed_label.text = str(slowness - value) + " / " + str(slowness)

func reset_speed_counter():
	speed_counter = slowness
