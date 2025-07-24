class_name Player extends CharacterBody2D

@export var SPEED = 100.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var cardinal_direction : Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	move_and_slide()

func get_anim_direction() -> String:	
	match cardinal_direction:
		Vector2.DOWN:
			return "down"
		Vector2.UP:
			return "up"
		Vector2.RIGHT:
			return "right"
		Vector2.LEFT:
			return "left"	
	return "down"
