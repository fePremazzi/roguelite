extends PlayerState

var isDashing : bool = true

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	print("Entering dash state")	
	player.animation_player.play("dash_" + player.get_anim_direction())
	player.animation_player.animation_finished.connect(end_dash)
	isDashing = true
	
## Called by the state machine on the engine's physics update tick _physics_process.
func physics_update(_delta: float) -> void:
	var input_direction := Input.get_vector("left", "right","up", "down")
	player.velocity.x = player.DASH_SPEED * input_direction.x
	player.velocity.y = player.DASH_SPEED * input_direction.y
	player.move_and_slide()
	
	if not isDashing:
		if is_equal_approx(input_direction.x, 0.0) and is_equal_approx(input_direction.y, 0.0):
			finished.emit(IDLE)
		elif Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			finished.emit(WALKING)
		elif Input.is_action_just_pressed("attack"):
			finished.emit(ATTACKING)
		
func exit() -> void:
	player.animation_player.animation_finished.disconnect(end_dash)
	
func end_dash(_newAnimName: String) -> void:
	isDashing = false
