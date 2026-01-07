class_name ThrowWoodAction
extends Action

var bonfire : BonfireObject

func _init(_bonfire : BonfireObject):
	bonfire = _bonfire


# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	checks.append(Precondition.check_is_object_valid(bonfire))
	
	checks.append(Globals.get_navigable_check(bonfire))
	
	return checks


# Override
func get_action_cost(
		agent_blackboard: GdPAIBlackboard, 
		_world_state: GdPAIBlackboard
) -> float:
	var agent_position: Vector2i = agent_blackboard.get_property("tilemap_position")
	
	var path = Globals.grid_system.get_navigation_path(agent_position, bonfire.tilemap_position, true)
	
	return 3 + path.size()


# Override
func get_preconditions() -> Array[Precondition]:
	var standing_next_to = Globals.get_standing_next_to_check(bonfire)
	
	var agent_holding_item = Precondition.agent_property_equal_to("holding_item", true)
	
	return [standing_next_to, agent_holding_item]


# Override
func simulate_effect(
		agent_blackboard: GdPAIBlackboard, 
		world_state: GdPAIBlackboard
):
	var path = Globals.grid_system.get_navigation_path( \
		agent_blackboard.get_property("tilemap_position"), bonfire.tilemap_position, true)
	
	if not path.is_empty():
		agent_blackboard.set_property("tilemap_position", path.back())
	
	var fire_strength = world_state.get_property("fire_strength")
	world_state.set_property("fire_strength", fire_strength + 20)
	
	agent_blackboard.set_property("holding_item", false)


# Override
func reverse_simulate_effect(
		agent_blackboard: GdPAIBlackboard, 
		world_state: GdPAIBlackboard
):
	#var fire_strength = world_state.get_property("fire_strength")
	#world_state.set_property("fire_strength", fire_strength - 20)
	#
	#agent_blackboard.set_property("holding_item", true)
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
	
	agent.entity.throw_wood(bonfire)
	
	return Action.Status.SUCCESS


# Override
func post_perform_action(_agent: GdPAIAgent) -> Action.Status:
	return Action.Status.SUCCESS

func get_title() -> String:
	return "Feed wood to bonfire"
