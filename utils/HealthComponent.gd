extends Node
class_name HealthComponent

signal zero_hp
signal hp_changed(change : int)
signal max_hp_changed(change : int)

@export var agent : GdPAIAgent

var _max_hp : int = 10 :
	set(value):
		_max_hp = value
		max_hp_changed.emit(value)

var _current_hp : int :
	set(value):
		if _current_hp != value:
			hp_changed.emit(value)
		else:
			return
		
		if value <= 0:
			_current_hp = 0
			zero_hp.emit()
		else:
			_current_hp = value

func _ready() -> void:
	# TODO calling here tries to use agent blackboard, which is null
	#reset_hp()
	assert(agent, "agent isn't set")

func receive_damage(damage : int):
	_current_hp -= damage
	
	if agent:
		agent.blackboard.set_property("health", _current_hp)

func reset_hp():
	_current_hp = _max_hp
	
	if agent:
		agent.blackboard.set_property("health", _max_hp)

func text():
	return str(_current_hp) + " / " + str(_max_hp)
