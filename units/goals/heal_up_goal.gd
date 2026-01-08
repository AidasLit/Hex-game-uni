class_name HealUpGoal
extends Goal

# Override
func compute_reward(agent: GdPAIAgent) -> float:
	# 0 - 100 linear
	# * 0.5 will map it to 0 - 50
	return clamp(100 - agent.blackboard.get_property("health"), 0, 100)

# Override
func get_desired_state(agent: GdPAIAgent) -> Array[Precondition]:
	var current_health = agent.blackboard.get_property("health")
	
	var health_increase: Precondition = Precondition.agent_property_greater_than("health", current_health)
	
	return [health_increase]

# Overload
func get_title() -> String:
	return "Heal up"

# Overload
func get_description() -> String:
	return "Heal up to avoid death"
