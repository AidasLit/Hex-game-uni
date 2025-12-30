class_name ChopTreesGoal
extends Goal

# Override
func compute_reward(_agent: GdPAIAgent) -> float:
	return Globals.world_blackboard.get_property("tree_count") * 10

# Override
func get_desired_state(_agent: GdPAIAgent) -> Array[Precondition]:
	var tree_count = Globals.world_blackboard.get_property("tree_count")
	
	#var some_trees: Precondition = Precondition.world_state_property_greater_than("tree_count", 0)
	var no_trees: Precondition = Precondition.world_state_property_less_than("tree_count", tree_count)
	
	return [no_trees]

# Overload
func get_title() -> String:
	return "Chop trees"

# Overload
func get_description() -> String:
	return "Navigate to the nearest trees and chop them down."
