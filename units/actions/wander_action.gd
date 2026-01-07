class_name WanderAction
extends Action

# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	
	var is_not_surrounded: Precondition = Precondition.new()
	is_not_surrounded.eval_func = func(blackboard: GdPAIBlackboard, _world_state: GdPAIBlackboard):
		var agent_position: Vector2i = blackboard.get_property("entity").tilemap_position
		
		var available_neighbors = Globals.grid_system.get_neighbors(agent_position)
		
		return not available_neighbors.is_empty()
	checks.append(is_not_surrounded)
	
	checks.append(Precondition.world_state_property_greater_than("fire_strength", 90))
	
	return checks


# Override
func get_action_cost(
		_agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
) -> float:
	return 1


# Override
func get_preconditions() -> Array[Precondition]:
	return []


# Override
func simulate_effect(
		agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
):
	var sim_position: Vector2i = agent_blackboard.get_property("tilemap_position")
	sim_position.x += 1
	agent_blackboard.set_property("tilemap_position", sim_position)


# Override
func reverse_simulate_effect(
		_agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
):
	pass


# Override
func pre_perform_action(agent: GdPAIAgent) -> Action.Status:
	var agent_position: Vector2i = agent.blackboard.get_property("tilemap_position")
	
	var possible_targets = Globals.grid_system.get_navigable_neighbors(agent_position)
	if possible_targets.is_empty():
		SignalBus.action_done.emit()
		return Action.Status.FAILURE
	
	var target_location : Vector2i = possible_targets.pick_random()
	agent.blackboard.set_property(uid_property("target_position"), target_location)
	
	return Action.Status.SUCCESS


# Override
func perform_action(
		agent: GdPAIAgent, 
		_delta: float
) -> Action.Status:
	if not agent.entity.is_active:
		return Action.Status.RUNNING
	
	var target_position: Vector2i = agent.blackboard.get_property(uid_property("target_position"))
	
	agent.entity.wander(target_position)
	
	return Action.Status.SUCCESS

# Override
func post_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.erase_property(uid_property("target_position"))
	return Action.Status.SUCCESS

# Override
func get_title() -> String:
	return "Wander"
