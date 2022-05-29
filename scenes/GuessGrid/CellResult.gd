extends Node2D

const result_colors = [
	Color("333333"), # not found
	Color("a98534"),  # not in the right spot
	Color("008358") # in the right spot
]

var result = -1
var color = Color()
var grow_height = 0

func _draw():
	if result != -1:
		draw_rect(Rect2(Vector2(0, floor(32 - grow_height * 0.5)), Vector2(64, grow_height)), color)

func _process(delta):
	if grow_height < 64:
		grow_height += delta * 256
	else:
		grow_height = 64
		set_process(false)
	update()

func set_result(value):
	result = value
	color = result_colors[value]
	grow_height = 0
	
	if result != -1:
		set_process(true)
	
	update()
