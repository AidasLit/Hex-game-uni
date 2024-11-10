extends Control
class_name HUD

@onready var deployable_units: HBoxContainer = $MarginContainer/HBoxContainer
const DEPLOYABLE_UNIT_TYPE = preload("res://main_scenes/deployable_unit_type.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	self.size = get_viewport().get_visible_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_deployable_units():
	self.show()
	
	var temp = DEPLOYABLE_UNIT_TYPE.instantiate()
	temp.set_amount(5)
	
	deployable_units.add_child(temp)
	
