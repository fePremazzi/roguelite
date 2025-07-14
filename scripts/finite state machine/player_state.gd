class_name PlayerState extends State

const IDLE = "idle"
const WALKING = "walk"
const ATTACKING = "attack"
const DASHING = "dash"

var player: Player
var cardinal_direction : Vector2 = Vector2.DOWN

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

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
