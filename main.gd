extends Node

const TOPLEFT = Vector2(-1, -1)
const TOPRIGHT = Vector2(1, -1)
const BOTTOMLEFT = Vector2(1, 1)
const BOTTOMRIGHT = Vector2(-1, 1)
const EXTENTS = 100

func _ready() -> void:
	get_window().mouse_passthrough = true

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

	# var topleft:Vector2 = get_viewport_rect().size/2
	# var topright:Vector2 = get_viewport_rect().size/2
	# var bottomleft:Vector2 = get_viewport_rect().size/2
	# var bottomright:Vector2 = get_viewport_rect().size/2

	var passarea:Rect2 = Rect2()
	passarea.position = get_viewport_rect().size

	var goobers:Array[Node2D] = []
	goobers.append_array(get_tree().get_nodes_in_group(&"entity_goober"))
	# goobers = sort_x_position(goobers)

	for g in goobers:
		var goober:Goober = g
		
		for v in goober.blocking:
			# var greaterthan_topleft = v.x < topleft.x and v.y < topleft.y
			# var greaterthan_topright = v.x > topright.x and v.y < topright.y
			# var greaterthan_bottomright = v.x > bottomright.x and v.y > bottomright.y
			# var greaterthan_bottomleft = v.x < bottomleft.x and v.y > bottomleft.y

			# if greaterthan_topright:
			# 	topright = v
			# if greaterthan_topleft:
			# 	topleft = v
			# if greaterthan_bottomleft:
			# 	bottomleft = v
			# if greaterthan_bottomright:
			# 	bottomright = v

			if v.x < passarea.position.x:
				passarea.position.x = v.x
			if v.x > passarea.size.x:
				passarea.size.x = v.x
			
			if v.y < passarea.position.y:
				passarea.position.y = v.y
			if v.y > passarea.size.y:
				passarea.size.y = v.y

	var topleft = passarea.position
	var topright = Vector2(passarea.size.x, passarea.position.y)

	var bottomleft = Vector2(passarea.position.x, passarea.size.y)
	var bottomright = passarea.size

	if get_window().has_focus():
		topleft = Vector2()
		bottomleft = Vector2(0, get_viewport_rect().size.y)
	
	DisplayServer.window_set_mouse_passthrough([
		topleft,
		topright,
		bottomright,
		bottomleft
	])