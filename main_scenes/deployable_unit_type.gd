extends Button
class_name DeployableUnitType

var amount = 0 :
	set(value):
		amount = value
		_update_amount()
	get:
		return amount

var id : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_amount():
	$MarginContainer/Label.text = str(amount)
