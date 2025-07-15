extends PlayerState

var isAttacking : bool = true

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	print("Entering attack state")
	player.velocity.x = 0.0
	player.velocity.y = 0.0
	super.enter(previous_state_path)
	player.animation_player.play("attack_" + get_anim_direction())
	isAttacking = false
	
## Called by the state machine on the engine's physics update tick _physics_process.
func physics_update(_delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if not isAttacking:
		if is_equal_approx(input_direction.x, 0.0) and is_equal_approx(input_direction.y, 0.0):
			finished.emit(IDLE)
		elif Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			finished.emit(WALKING)
