class_name Walk extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	cardinal_direction = Input.get_vector("left", "right", "up", "down")
	player.animation_player.play("walk_" + get_anim_direction())

func physics_update(_delta: float) -> void:
	var input_direction := Input.get_vector("left", "right","up", "down")
	player.velocity.x = player.SPEED * input_direction.x
	player.velocity.y = player.SPEED * input_direction.y
	player.move_and_slide()

	if is_equal_approx(input_direction.x, 0.0) and is_equal_approx(input_direction.y, 0.0):
		finished.emit(IDLE)
	elif Input.is_action_just_pressed("attack"):
		finished.emit(ATTACKING)
	elif Input.is_action_just_pressed("dash"):
		finished.emit(DASHING)
