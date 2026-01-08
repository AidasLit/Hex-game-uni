class_name EnterHealingAction
extends Action

var health_space : HealthSpace

func _init(_health_space : HealthSpace):
	health_space = _health_space


# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	checks.append(Precondition.check_is_object_valid(health_space))
	
	checks.append(Globals.get_navigable_check(health_space))
	
	return checks


# Override
func get_action_cost(
		agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
) -> float:
	var agent_position: Vector2i = agent_blackboard.get_property("tilemap_position")
	
	var path = Globals.grid_system.get_navigation_path(agent_position, health_space.tilemap_position)
	
	return 0 + path.size() - 1


# Override
func get_preconditions() -> Array[Precondition]:
	var standing_on = Globals.get_standing_on_check(health_space)
	
	return [standing_on]


# Override
func simulate_effect(
		agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
):
	var path = Globals.grid_system.get_navigation_path( \
		agent_blackboard.get_property("tilemap_position"), 
		health_space.tilemap_position,
		agent_blackboard.get_property("real_tilemap_position"))
	
	if not path.is_empty():
		agent_blackboard.set_property("tilemap_position", path.back())
	
	var agent_health = agent_blackboard.get_property("health")
	agent_blackboard.set_property("health", agent_health + 80)


# Override
func reverse_simulate_effect(
		_agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
):
	pass


# Override
func pre_perform_action(_agent: GdPAIAgent) -> Action.Status:
	return Action.Status.SUCCESS


# Override
func perform_action(
		agent: GdPAIAgent, 
		_delta: float
) -> Action.Status:
	if not agent.entity.is_active:
		return Action.Status.RUNNING
	
	var standing_on = Globals.get_standing_on_check(health_space)
	
	if standing_on.evaluate(agent.blackboard, Globals.world_blackboard):
		return Action.Status.SUCCESS
	else:
		agent.entity.step(health_space.tilemap_position)
		return Action.Status.RUNNING


# Override
func post_perform_action(_agent: GdPAIAgent) -> Action.Status:
	return Action.Status.SUCCESS

func get_title() -> String:
	return "Feed wood to bonfire"
