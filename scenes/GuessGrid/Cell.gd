extends Sprite

const margin_pos = Vector2(4, 4)

onready var letter_label = get_node("LetterLabel")
onready var cell_result = get_node("CellResult")

var shake_x_value = 0
var original_pos = Vector2()

func _ready():
	set_offset(margin_pos)
	letter_label.set_pos(margin_pos)
	cell_result.set_pos(margin_pos)
	
	original_pos = get_pos()

func _process(delta):
	if shake_x_value <= 0:
		shake_x_value = 0
		
		set_pos(original_pos)
		
		set_process(false)
	else:
		set_pos(original_pos + Vector2(sin(shake_x_value), 0) * 8)
		shake_x_value -= 0.5

func set_result(value):
	cell_result.set_result(value)

func set_text(text):
	letter_label.set_text(text)

func shake():
	shake_x_value = PI * 4
	set_process(true)

func reset():
	set_text("")
	cell_result.set_result(-1)
	
	shake_x_value = 0
	
	set_offset(margin_pos)
	
	set_process(false)

func draw_rect_outline(rect, color):
	var previous_point = rect.pos
	var next_point = Vector2(rect.pos.x + rect.size.x, rect.pos.y)
	draw_line(previous_point, next_point, color, 1)
	previous_point = next_point
	next_point = Vector2(rect.pos.x + rect.size.x, rect.pos.y + rect.size.y)
	draw_line(previous_point, next_point, color, 1)
	previous_point = next_point
	next_point = Vector2(rect.pos.x, rect.pos.y + rect.size.y)
	draw_line(previous_point, next_point, color, 1)
	previous_point = next_point
	next_point = rect.pos
	draw_line(previous_point, next_point, color, 1)
