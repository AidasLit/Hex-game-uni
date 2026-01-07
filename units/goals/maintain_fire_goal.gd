class_name MaintainFireGoal
extends Goal

# Override
func compute_reward(_agent: GdPAIAgent) -> float:
	if Globals.world_blackboard.get_property("tree_count") == 0 and\
		Globals.world_blackboard.get_property("wood_count") == 0:
		return 0
	return clamp(100 - Globals.world_blackboard.get_property("fire_strength"), 0, 100)

# Override
func get_desired_state(_agent: GdPAIAgent) -> Array[Precondition]:
	var current_fire_strength = Globals.world_blackboard.get_property("fire_strength")
	
	var fire_increased: Precondition = Precondition.world_state_property_greater_than("fire_strength", current_fire_strength)
	
	return [fire_increased]

# Overload
func get_title() -> String:
	return "Maintain fire"

# Overload
func get_description() -> String:
	return "Make sure the bonfire on the map doesn't go out"
