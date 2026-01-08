class_name TakeWoodAction
extends Action

var wood : WoodObject

func _init(_wood : WoodObject):
	wood = _wood


# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	checks.append(Precondition.check_is_object_valid(wood))
	
	checks.append(Globals.get_navigable_check(wood))
	
	return checks


# Override
func get_action_cost(
		agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
) -> float:
	var agent_position: Vector2i = agent_blackboard.get_property("tilemap_position")
	
	var path = Globals.grid_system.get_navigation_path(agent_position, wood.tilemap_position)
	
	return 0 + path.size() - 1


# Override
func get_preconditions() -> Array[Precondition]:
	var standing_next_to = Globals.get_standing_next_to_check(wood)
	
	var agent_not_holding_item = Precondition.agent_property_equal_to("holding_item", false)
	
	return [standing_next_to, agent_not_holding_item]


# Override
func simulate_effect(
		agent_blackboard: GdPAIBlackboard, 
		world_state: GdPAIBlackboard
):
	var path = Globals.grid_system.get_navigation_path( \
		agent_blackboard.get_property("tilemap_position"), 
		wood.tilemap_position,
		agent_blackboard.get_property("real_tilemap_position"))
	
	if not path.is_empty():
		path.pop_back()
		agent_blackboard.set_property("tilemap_position", path.back())
	
	var free_wood_count = world_state.get_property("free_wood_count")
	world_state.set_property("free_wood_count", free_wood_count - 1)
	
	agent_blackboard.set_property("holding_item", true)


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
	
	var standing_next_to = Globals.get_standing_next_to_check(wood)
	
	if standing_next_to.evaluate(agent.blackboard, Globals.world_blackboard):
		agent.entity.take_wood(wood)
		return Action.Status.SUCCESS
	else:
		agent.entity.step(wood.tilemap_position)
		return Action.Status.RUNNING


# Override
func post_perform_action(_agent: GdPAIAgent) -> Action.Status:
	return Action.Status.SUCCESS

func get_title() -> String:
	return "Chop tree"
