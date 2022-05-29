extends Node2D

const result_colors = [
	Color("333333"), # not found
	Color("a98534"),  # not in the right spot
	Color("008358") # in the right spot
]
const active_color = Color("ffffff")
const margin_pos = Vector2(2, 2)

onready var letter_label = get_node("LetterLabel")

var letter = ""
var active = false
var color = Color("555555")
var result = -1

func _ready():
	letter_label.set_pos(margin_pos)
	letter_label.set_text(letter)

func _draw():
	if active:
		draw_rect(Rect2(Vector2(), Vector2(40, 40) + margin_pos * 2), active_color)
	
	draw_rect(Rect2(margin_pos, Vector2(40, 40)), color)

func reset():
	active = false
	color = Color("555555")
	result = -1
	update()

func set_result(value):
	if value > result:
		result = value
		color = result_colors[value]
		update()

func set_letter(value):
	letter = value
	
	if letter_label != null:
		letter_label.set_text(letter)

func set_active(value):
	active = value
	update()