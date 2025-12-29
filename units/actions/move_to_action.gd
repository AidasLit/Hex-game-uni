class_name MoveToAction
extends Action

var target : Vector2i

# Override
func _init(_target: Vector2i):
	# If implementing _init(), make sure to call super() so a uid is created.
	super()
	
	target = _target


# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = []
	checks.append(Precondition.agent_has_property("entity"))
	checks.append(Precondition.agent_has_property("tilemap_position"))
	checks.append(Precondition.agent_property_equal_to("is_active", true))
	
	var can_get_to_check: Precondition = Precondition.new()
	can_get_to_check.eval_func = func(blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
		var agent_position: Vector2i = blackboard.get_property("tilemap_position")
		
		var path = Globals.grid_system.get_navigation_path(agent_position, target, true)
		
		var next_to_target = path.back()
		blackboard.set_property("tilemap_position", next_to_target)
		
		print("\nVALIDITY: MoveTo - target navigable: ", not path.is_empty())
		
		return not path.is_empty()
	checks.append(can_get_to_check)
	
	return checks


# Override
func get_action_cost(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard) -> float:
	return 1


# Override
func get_preconditions() -> Array[Precondition]:
	var conditions: Array[Precondition] = []
	#conditions.append(Precondition.agent_property_not_equal_to("tilemap_position", target))
	return conditions


# Override
func simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	var path = Globals.grid_system.get_navigation_path(agent_blackboard.get_property("tilemap_position"), target, true)
	var next_to_target = path.back()
	
	print("SIMULATION: MoveTo - final position: ", next_to_target)
	agent_blackboard.set_property("tilemap_position", next_to_target)


# Override
func reverse_simulate_effect(agent_blackboard: GdPAIBlackboard, world_state: GdPAIBlackboard):
	pass


# Override
func pre_perform_action(agent: GdPAIAgent) -> Action.Status:
	# Cache location data.
	var agent_position: Vector2i = agent.blackboard.get_property("tilemap_position")
	agent.blackboard.set_property(uid_property("tilemap_position"), agent_position)
	
	if agent.blackboard.get_property("path_length"):
		Globals.action_done.emit()
		return Action.Status.FAILURE
	
	agent.blackboard.set_property(uid_property("target_location"), target)
	
	print("\nACTION: MoveTo - from ", agent_position, " to next to: ", target)
	return Action.Status.SUCCESS


# Override
func perform_action(agent: GdPAIAgent, delta: float) -> Action.Status:
	var target_location = agent.blackboard.get_property(uid_property("target_location"))
	
	Globals.play_loop.move(target_location, true)
	
	agent.blackboard.get_property("entity").is_active = false
	return Action.Status.SUCCESS


# Override
func post_perform_action(agent: GdPAIAgent) -> Action.Status:
	agent.blackboard.erase_property(uid_property("tilemap_position"))
	agent.blackboard.erase_property(uid_property("target_location"))

	return Action.Status.SUCCESS

func get_title() -> String:
	return "Move to"
