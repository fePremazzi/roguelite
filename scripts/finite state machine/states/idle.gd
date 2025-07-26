extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	print("Entering idle state")
	
	player.velocity.x = 0.0
	player.velocity.y = 0.0
	player.animation_player.play("idle_" + player.get_anim_direction())

func physics_update(_delta: float) -> void:
	var input_direction := Input.get_vector("left", "right","up", "down")
	player.velocity.x = player.SPEED * input_direction.x
	player.velocity.y = player.SPEED * input_direction.y
	player.move_and_slide()

	if Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		finished.emit(WALKING)
	elif Input.is_action_just_pressed("attack"):
		finished.emit(ATTACKING)
	elif Input.is_action_just_pressed("dash"):
		finished.emit(DASHING)
