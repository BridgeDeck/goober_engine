extends AnimatedSprite2D
class_name Goober

const FLOOR_POSITION = 100.0
# const SPEED = 300.0
# const ACCELERATE = SPEED * 2
# const GRAVITY = 300.0
# const JUMPFORCE = 300.0
# const HOPFORCE = 75.0
# const WALL_OFFSET = 200.0
# const HARDWALL_OFFSET = -0.0

# const TIME_JUMP_MINIMUM = 5.0
# const TIME_JUMP_MAXIMUM = 7.5

# const TIME_PAUSE_MINIMUM = 2.0
# const TIME_PAUSE_MAXIMUM = 10.0

# const TIME_TOPAUSE_MINIMUM = 1.0
# const TIME_TOPAUSE_MAXIMUM = 3.0

@export var speed:float = 300.0
@export var accelerate:float = 600.0
@export var gravity:float = 300.0
@export var jumpforce:float = 300.0
@export var hopforce:float = 75.0

@export var time_jump_minimum:float = 5.0
@export var time_jump_maximum:float = 7.5

@export var time_topause_minimum:float = 2.0
@export var time_topause_maximum:float = 10.0

@export var time_pause_minimum:float = 1.0
@export var time_pause_maximum:float = 5.0

var jump_flip:float = TAU

var global_rect:Rect2 :
	get():
		var output = Rect2()
		output.position = resolution/2
		output.end = resolution/2

		for v2 in blocking:
			if v2.x < output.position.x:
				output.position.x = v2.x
			if v2.y < output.position.y:
				output.position.y = v2.y
			
			if v2.x > output.end.x:
				output.end.x = v2.x
			if v2.y > output.end.y:
				output.end.y = v2.y
		
		return output

var blocking:PackedVector2Array :
	get():
		if not is_node_ready():
			await ready
		var oldp:Array = $MouseOver/Hitbox.polygon
		var newp = oldp.map(func(v:Vector2):
			return $MouseOver/Hitbox.global_position + v.rotated(rotation))
		return newp


var resolution:Vector2 :
	get():
		return get_viewport_rect().size

var apply_rot:float
var horizontal_speed:float

var velocity:Vector2 = Vector2.ZERO

var pause_time:float = 0.0

var to_pause:float = 0.0
var to_jump:float = 0.0
var to_hop:bool = false

var floor_position_y:float :
	get():
		return resolution.y - FLOOR_POSITION

var is_on_floor:bool :
	get():
		return position.y >= floor_position_y

var is_beyond_left_side:bool :
	get():
		var mainnode:MainNode = get_tree().get_first_node_in_group(&"main_node")
		return position.x < mainnode.softlimit_left.value

var is_beyond_right_side:bool :
	get():
		var mainnode:MainNode = get_tree().get_first_node_in_group(&"main_node")
		return position.x > mainnode.softlimit_right.value

var is_going_left:bool :
	get():
		return horizontal_speed < 0.0

var is_going_right:bool :
	get():
		return horizontal_speed > 0.0

var is_mouse_over:bool :
	get():
		return $Bounds.get_global_rect().has_point($Bounds.get_global_mouse_position())

var dragging:bool = false
var dragging_base:Vector2 = Vector2.ZERO
var dragging_delta:Vector2 = Vector2.ZERO

func _ready() -> void:
	horizontal_speed = speed
	to_pause = time_topause_maximum
	to_jump = time_jump_minimum
	# $MouseOver.mouse_entered.connect(func():
	# 	is_mouse_over = true)
	# $MouseOver.mouse_exited.connect(func():
	# 	is_mouse_over = false)
	
	# $MouseOver.input_event.connect(_mouse_over_input_event)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mevent:InputEventMouseButton = event
		var left_click = mevent.button_index == MOUSE_BUTTON_LEFT
		var left_click_pressed = left_click and not mevent.is_echo() and mevent.is_pressed()
		var left_click_released = left_click and not mevent.is_pressed()

		if is_mouse_over and left_click_pressed:
			dragging = true
			dragging_base = global_position
			dragging_delta = Vector2.ZERO

		if left_click_released:
			dragging = false
		
	if event is InputEventMouseMotion:
		var mevent:InputEventMouseMotion = event

		dragging_delta += mevent.screen_relative
		

func _process(delta: float) -> void:

	var is_paused:bool = pause_time > 0.0

	if is_on_floor:
		frame = 0
		position.y = floor_position_y
		
		if not is_paused:
			to_jump -= delta
		
		if to_hop:
			to_hop = false
			to_jump = lerpf(time_jump_minimum, time_jump_maximum, randf())
			velocity.y = -hopforce
		elif to_jump <= 0.0:
			to_jump = lerpf(time_jump_minimum, time_jump_maximum, randf())
			velocity.y = -jumpforce
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
		frame = 1
		velocity.y += gravity*delta


	if is_beyond_left_side:
		horizontal_speed = speed
	elif is_beyond_right_side:
		horizontal_speed = -speed


	var target_hori = horizontal_speed

	if is_paused:
		pause_time -= delta
		target_hori = 0.0
	else:
		to_pause -= delta
		if to_pause <= 0.0 and is_on_floor:
			if randi() % 2 == 1:
				horizontal_speed = -horizontal_speed
			to_pause = lerpf(time_topause_minimum, time_topause_maximum, randf())
			pause_time = lerpf(time_pause_minimum, time_pause_maximum, randf())
	
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
		velocity.x = move_toward(velocity.x, target_hori, accelerate*delta)


	var mainnode:MainNode = get_tree().get_first_node_in_group(&"main_node")
	if dragging:
		position = dragging_base + dragging_delta
		velocity = Vector2.ZERO
	else:
		position += velocity*delta
	position.x = clampf(position.x, mainnode.hardlimit_left.value, mainnode.hardlimit_right.value)

# Utility function for rounding to a decimal point, honestly Godot should add a builtin one.
static func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
