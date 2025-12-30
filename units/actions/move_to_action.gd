class_name MoveToAction
extends Action

var target : Vector2i

func _init(_target: Vector2i):
	target = _target


# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	
	var can_get_to_check: Precondition = Precondition.new()
	can_get_to_check.eval_func = func(blackboard: GdPAIBlackboard, _world_state: GdPAIBlackboard):
		var agent_position: Vector2i = blackboard.get_property("tilemap_position")
		
		var path = Globals.grid_system.get_navigation_path(agent_position, target, true)
		
		return not path.is_empty()
	checks.append(can_get_to_check)
	
	return checks


# Override
func get_action_cost(
		agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
) -> float:
	var agent_position: Vector2i = agent_blackboard.get_property("tilemap_position")
	
	var path = Globals.grid_system.get_navigation_path(agent_position, target, true)
	
	return path.size()


# Override
func get_preconditions() -> Array[Precondition]:
	var conditions: Array[Precondition] = []
	return conditions


# Override
func simulate_effect(
		agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
):
	var path = Globals.grid_system.get_navigation_path(agent_blackboard.get_property("tilemap_position"), target, true)
	var next_to_target = path.back()
	
	agent_blackboard.set_property("tilemap_position", next_to_target)


# Override
func reverse_simulate_effect(
		_agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
):
	pass


# Override
func pre_perform_action(agent: GdPAIAgent) -> Action.Status:
	# Cache location data.
	var agent_position: Vector2i = agent.blackboard.get_property("tilemap_position")
	agent.blackboard.set_property(uid_property("tilemap_position"), agent_position)
	
	if agent.blackboard.get_property("path_length"):
		Globals.action_done.emit()
		return Action.Status.FAILURE
	
	agent.blackboard.set_property(uid_property("target_position"), target)
	
	
	return Action.Status.SUCCESS


# Override
func perform_action(
		agent: GdPAIAgent, 
		_delta: float
) -> Action.Status:
	var start_position: Vector2i = agent.blackboard.get_property(uid_property("tilemap_position"))
	var target_position = agent.blackboard.get_property(uid_property("target_position"))
	
	if start_position == agent.get_parent().tilemap_position:
		Globals.play_loop.move(target_position, true)
	
	var available_neighbors = Globals.grid_system.get_neighbors(target_position)
	
	if available_neighbors.has(agent.get_parent().tilemap_position):
		return Action.Status.SUCCESS
	
	return Action.Status.RUNNING


# Override
func post_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.erase_property(uid_property("tilemap_position"))
	agent.blackboard.erase_property(uid_property("target_position"))
	return Action.Status.SUCCESS

func get_title() -> String:
	return "Move to"
