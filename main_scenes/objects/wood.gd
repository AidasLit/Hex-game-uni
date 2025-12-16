extends Node2D

var anchor : Marker2D = null

func _physics_process(delta: float) -> void:
	if anchor:
		global_position = anchor.global_position
