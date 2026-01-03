extends Node
class_name HealthComponent

signal zero_hp
signal hp_changed(change : int)
signal max_hp_changed(change : int)

@export var object : Node

var _max_hp : int = 10 :
	set(value):
		_max_hp = value
		max_hp_changed.emit(value)

var _current_hp : int :
	set(value):
		if _current_hp == value:
			return
		
		if value <= 0:
			_current_hp = 0
			zero_hp.emit()
		elif value > _max_hp:
			_current_hp = _max_hp
		else:
			_current_hp = value
		
		hp_changed.emit(_current_hp)

func _ready() -> void:
	# TODO calling here tries to use agent blackboard, which is null
	#reset_hp()
	assert(object, "object isn't set")

func receive_damage(damage : int):
	_current_hp -= damage
	
	if object is PlayableUnit:
		object.agent.blackboard.set_property("health", _current_hp)

func reset_hp():
	_current_hp = _max_hp
	
	if object is PlayableUnit:
		object.agent.blackboard.set_property("health", _max_hp)

func text():
	return str(_current_hp) + " / " + str(_max_hp)
