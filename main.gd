extends Node
class_name MainNode

const TOPLEFT = Vector2(-1, -1)
const TOPRIGHT = Vector2(1, -1)
const BOTTOMLEFT = Vector2(1, 1)
const BOTTOMRIGHT = Vector2(-1, 1)
const EXTENTS = 100

@onready var hardlimit_left:HSlider = $Settings/v1/WallHard/v2/Left/Value
@onready var hardlimit_right:HSlider = $Settings/v1/WallHard/v2/Right/Value

@onready var softlimit_left:HSlider = $Settings/v1/WallSoft/v2/Left/Value
@onready var softlimit_right:HSlider = $Settings/v1/WallSoft/v2/Right/Value

func setup_wallslider(slider:HSlider):
	slider.min_value = 0.0
	slider.max_value = get_viewport().get_visible_rect().size.x

func _ready() -> void:
	var resolution:Vector2 = get_viewport().get_visible_rect().size

	setup_wallslider(softlimit_left)
	setup_wallslider(softlimit_right)
	setup_wallslider(hardlimit_left)
	setup_wallslider(hardlimit_right)

	hardlimit_left.value = 0.0
	hardlimit_right.value = resolution.x

	softlimit_left.value = hardlimit_left.value + 200
	softlimit_right.value = hardlimit_right.value - 200

# From smallest x to largest x position
func sort_x_position(input:Array[Node2D])->Array[Node2D]:
	var item_idx = 1
	var output:Array[Node2D] = []
	output.resize(input.size())

	var has_shifted = false

	while item_idx < input.size():
		var x_current:Node2D = input[item_idx]
		var x_previous:Node2D = input[item_idx-1]

		if x_previous.global_position.x > x_current.global_position.x:
			output[item_idx]=x_previous
			output[item_idx-1]=x_current
			has_shifted = true
		else:
			output[item_idx-1]=x_previous
			output[item_idx]=x_current
		item_idx += 1
	
	if has_shifted:
		return sort_x_position(output)
	else:
		return output

func _process(delta: float) -> void:

	var resolution:Vector2 = get_viewport().get_visible_rect().size

	var passarea:Rect2 = Rect2()
	passarea.position = resolution

	var goobers:Array[Node2D] = []
	goobers.append_array(get_tree().get_nodes_in_group(&"entity_goober"))

	for g in goobers:
		var goober:Goober = g
		
		for v in goober.blocking:

			if v.x < passarea.position.x:
				passarea.position.x = v.x
			if v.x > passarea.size.x:
				passarea.size.x = v.x
			
			if v.y < passarea.position.y:
				passarea.position.y = v.y
			if v.y > passarea.size.y:
				passarea.size.y = v.y

	var topleft
	var topright

	var bottomleft
	var bottomright

	$Settings.visible = get_window().has_focus()
	$LimitsVisualizer.visible = get_window().has_focus()
	if get_window().has_focus():
		if hardlimit_left.has_focus():
			hardlimit_left.value = clampf(hardlimit_left.value, 0.0, hardlimit_right.value)
			softlimit_left.value = clampf(softlimit_left.value, hardlimit_left.value, hardlimit_right.value)
			softlimit_right.value = clampf(softlimit_right.value, hardlimit_left.value, hardlimit_right.value)
		if hardlimit_right.has_focus():
			hardlimit_right.value = clampf(hardlimit_right.value, hardlimit_left.value, resolution.x)
			softlimit_left.value = clampf(softlimit_left.value, hardlimit_left.value, hardlimit_right.value)
			softlimit_right.value = clampf(softlimit_right.value, hardlimit_left.value, hardlimit_right.value)
		
		if softlimit_left.has_focus():
			softlimit_left.value = clampf(softlimit_left.value, hardlimit_left.value, softlimit_right.value)
		
		if softlimit_right.has_focus():
			softlimit_right.value = clampf(softlimit_right.value, softlimit_left.value, hardlimit_right.value)
		
		$LimitsVisualizer/SoftLimitLeft.offset_right = softlimit_left.value
		$LimitsVisualizer/SoftLimitRight.offset_left = softlimit_right.value - resolution.x

		$LimitsVisualizer/HardLimitLeft.offset_right = hardlimit_left.value
		$LimitsVisualizer/HardLimitRight.offset_left = hardlimit_right.value - resolution.x

		topleft = Vector2()
		topright = Vector2(resolution.x, 0.0)
		bottomleft = Vector2(0, resolution.y)
		bottomright = resolution
	else:
		topleft = passarea.position
		topright = Vector2(passarea.size.x, passarea.position.y)

		bottomleft = Vector2(passarea.position.x, passarea.size.y)
		bottomright = passarea.size

	
	get_window().mouse_passthrough = false
	get_window().mouse_passthrough_polygon = [
		topleft,
		topright,
		bottomright,
		bottomleft
	]
