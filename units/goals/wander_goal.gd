class_name WanderGoal
extends Goal


# Override
func compute_reward(agent: GdPAIAgent) -> float:
	return 10


# Override
func get_desired_state(agent: GdPAIAgent) -> Array[Precondition]:
	return []


# Overload
func get_title() -> String:
	return "Wander around"


# Overload
func get_description() -> String:
	return "Move around the environment."
