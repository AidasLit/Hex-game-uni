class_name ChopTreesGoal
extends Goal

# Override
func compute_reward(agent: GdPAIAgent) -> float:
	return Globals.world_blackboard.get_property("tree_count") * 10

# Override
func get_desired_state(agent: GdPAIAgent) -> Array[Precondition]:
	
	#var some_trees: Precondition = Precondition.world_state_property_greater_than("tree_count", 0)
	var no_trees: Precondition = Precondition.world_state_property_equal_to("tree_count", 0)
	
	return [no_trees]

# Overload
func get_title() -> String:
	return "Chop trees"

# Overload
func get_description() -> String:
	return "Navigate to the nearest trees and chop them down."
