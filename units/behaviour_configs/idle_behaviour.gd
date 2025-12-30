class_name IdleBehaviorConfig
extends GdPAIBehaviorConfig
## Behavior configuration for agents that wander around the environment.

# Override
func _self_init() -> void:
	super()
	goals.append(WanderGoal.new())
	self_actions.append(WanderAction.new())
