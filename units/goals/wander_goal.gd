class_name WanderGoal
extends Goal

# Override
func compute_reward(_agent: GdPAIAgent) -> float:
	return 5

# Override
func get_desired_state(agent: GdPAIAgent) -> Array[Precondition]:
	var agent_position: Vector2i = agent.blackboard.get_property("tilemap_position")
	
	var move_condition: Precondition = Precondition.new()
	move_condition.eval_func = func(blackboard: GdPAIBlackboard, _world_state: GdPAIBlackboard):
		var sim_position: Vector2i = blackboard.get_property("tilemap_position")
		
		var x_diff = abs(agent_position.x - sim_position.x)
		var y_diff = abs(agent_position.y - sim_position.y)
		
		return x_diff >= 1 || y_diff >= 1
	
	return [move_condition]

# Overload
func get_title() -> String:
	return "Wander around"

# Overload
func get_description() -> String:
	return "Move around the environment."
