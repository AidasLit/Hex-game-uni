extends Node
class_name HealthComponent

@export var max_hp : int

signal zero_hp
signal hp_changed(change : int)

var current_hp : int :
	set(value):
		if current_hp != value:
			hp_changed.emit(value)
		else:
			return
		
		if value <= 0:
			current_hp = 0
			zero_hp.emit()
		else:
			current_hp = value

func _ready() -> void:
	current_hp = max_hp

func _process(_delta: float) -> void:
	pass

func receive_damage(damage : int):
	current_hp -= damage
