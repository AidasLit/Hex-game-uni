class_name ChopTreesGoal
extends Goal

# Override
func compute_reward(agent: GdPAIAgent) -> float:
	return 30

# Override
func get_desired_state(agent: GdPAIAgent) -> Array[Precondition]:
	
	var desired_condition: Precondition = Precondition.world_state_property_equal_to("tree_count", 0)
	
	return [desired_condition]

# Overload
func get_title() -> String:
	return "Chop trees"

# Overload
func get_description() -> String:
	return "Navigate to the nearest trees and chop them down."
