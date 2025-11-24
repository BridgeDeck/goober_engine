extends AnimatedSprite2D
class_name Goober

const FLOOR_POSITION = 100.0
const SPEED = 300.0
const ACCELERATE = SPEED * 2
const GRAVITY = 300.0
const JUMPFORCE = 300.0
const WALL_OFFSET = 50.0
const HARDWALL_OFFSET = -100.0

const TIME_JUMP_MINIMUM = 5.0
const TIME_JUMP_MAXIMUM = 7.5

const TIME_PAUSE_MINIMUM = 2.0
const TIME_PAUSE_MAXIMUM = 10.0

const TIME_TOPAUSE_MINIMUM = 1.0
const TIME_TOPAUSE_MAXIMUM = 3.0

@export var jump_flip:float = TAU

var blocking:PackedVector2Array :
	get():
		if not is_node_ready():
			await ready
		var oldp:Array = $MouseOver/Hitbox.polygon
		var newp = oldp.map(func(v:Vector2):
			return $MouseOver/Hitbox.global_position + v)
		return newp


var resolution:Vector2 :
	get():
		return get_viewport_rect().size

var apply_rot:float
var horizontal_speed = SPEED

var velocity:Vector2 = Vector2.ZERO

var pause_time:float = 0.0

var to_pause:float = TIME_TOPAUSE_MAXIMUM
var to_jump:float = TIME_JUMP_MINIMUM

var floor_position_y:float :
	get():
		return resolution.y - FLOOR_POSITION

var is_on_floor:bool :
	get():
		return position.y >= floor_position_y

var is_beyond_left_side:bool :
	get():
		return position.x < WALL_OFFSET

var is_beyond_right_side:bool :
	get():
		return position.x > resolution.x - WALL_OFFSET

var is_going_left:bool :
	get():
		return horizontal_speed < 0.0

var is_going_right:bool :
	get():
		return horizontal_speed > 0.0

var is_mouse_over:bool
		
func _ready() -> void:
	$MouseOver.mouse_entered.connect(func():
		is_mouse_over = true)
	$MouseOver.mouse_exited.connect(func():
		is_mouse_over = false)
func _process(delta: float) -> void:

	var is_paused:bool = pause_time > 0.0

	if is_on_floor:
		position.y = floor_position_y
		
		if not is_paused:
			to_jump -= delta
		
		if to_jump <= 0.0:
			to_jump = lerpf(TIME_JUMP_MINIMUM, TIME_JUMP_MAXIMUM, randf())
			velocity.y = -JUMPFORCE
			var rotate_tween = create_tween().tween_property(
				self,
				"rotation",
				rotation + jump_flip,
				1.0
			)
			rotate_tween.set_trans(Tween.TRANS_SINE)
			rotate_tween.set_ease(Tween.EASE_IN_OUT)

		else:
			velocity.y = 0.0
	else:
		velocity.y += GRAVITY*delta


	if is_beyond_left_side:
		horizontal_speed = SPEED
	elif is_beyond_right_side:
		horizontal_speed = -SPEED


	var target_hori = horizontal_speed

	if is_paused:
		pause_time -= delta
		target_hori = 0.0
	else:
		to_pause -= delta
		if to_pause <= 0.0 and is_on_floor:
			to_pause = lerpf(TIME_TOPAUSE_MINIMUM, TIME_TOPAUSE_MAXIMUM, randf())
			pause_time = lerpf(TIME_PAUSE_MINIMUM, TIME_PAUSE_MAXIMUM, randf())
	
	if $Debug.visible:
		$Debug/ToPause/Value.text = str(round_to_dec(to_pause, 2))
		$Debug/Pause/Value.text = str(round_to_dec(pause_time, 2))
		$Debug/ToJump/Value.text = str(round_to_dec(to_jump, 2))

	flip_h = is_going_right

	if is_going_right:
		jump_flip = TAU
	elif is_going_left:
		jump_flip = -TAU

	if is_on_floor:
		velocity.x = move_toward(velocity.x, target_hori, ACCELERATE*delta)


	position += velocity*delta
	position.x = clampf(position.x, HARDWALL_OFFSET, resolution.x - HARDWALL_OFFSET)

# Utility function for rounding to a decimal point, honestly Godot should add a builtin one.
static func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
