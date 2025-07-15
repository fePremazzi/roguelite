class_name PlayerState extends State

const IDLE = "Idle"
const WALKING = "Walk"
const ATTACKING = "Attack"
const DASHING = "Dash"

var player: Player
var cardinal_direction : Vector2 = Vector2.DOWN

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	cardinal_direction = Input.get_vector("left", "right", "up", "down")

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
