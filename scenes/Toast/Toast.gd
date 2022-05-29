extends Node2D

const show_x = 960
const hide_x = 1280
const y = 32
const move_speed = 1200

onready var message_label = get_node("MessageLabel")

var x = hide_x
var show_frames = 0
var show = false

func _ready():
	set_pos(Vector2(x, y))
	set_hidden(true)

func _process(delta):
	if show:
		if x > show_x:
			x -= delta * move_speed
			set_pos(Vector2(x, y))
		else: 
			x = show_x
			set_pos(Vector2(x, y))
			show = false
	else:
		if show_frames > 0:
			show_frames -= delta
		elif x < hide_x:
			x += delta * move_speed
			set_pos(Vector2(x, y))
		else:
			x = hide_x
			set_pos(Vector2(x, y))
			set_hidden(true)
			set_process(false)

func show_toast(message):
	message_label.set_text(message)
	
	show = true
	show_frames = 3
	set_hidden(false)
	set_process(true)
	