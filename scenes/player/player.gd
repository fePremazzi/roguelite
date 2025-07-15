class_name Player extends CharacterBody2D

@export var SPEED = 100.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	move_and_slide()
