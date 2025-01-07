extends Node
class_name HealthComponent

signal zero_hp
signal hp_changed(change : int)
signal max_hp_changed(change : int)

var max_hp : int = 10 :
	set(value):
		max_hp = value
		max_hp_changed.emit(value)

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
	reset_hp()

func _process(_delta: float) -> void:
	pass

func receive_damage(damage : int):
	current_hp -= damage

func reset_hp():
	current_hp = max_hp
