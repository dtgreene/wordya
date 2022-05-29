extends Node2D

const IndicatorScene = preload("res://scenes/LoadingIndicator/LoadingIndicator.tscn")

const box_color = Color("5539a7")
const box_size = Vector2(300, 50)
const active_color = Color("ffffff")
const margin_pos = Vector2(2, 2)

onready var button_label = get_node("ButtonLabel")

export var button_text = ""

var active = false
var loading = false

func _ready():
	button_label.set_text(button_text)

func _draw():
	if active:
		draw_rect(Rect2(-margin_pos, box_size + margin_pos * 2), active_color)
	
	draw_rect(Rect2(Vector2(), box_size), box_color)

func set_active(value):
	active = value
	update()

func set_loading(value):
	if value:
		if !loading: 
			loading = true
			button_label.set_hidden(true)
			var instance = IndicatorScene.instance()
			instance.set_pos(Vector2(150, 25))
			add_child(instance)
	else:
		if loading:
			loading = false
			button_label.set_hidden(false)
			var indicator = get_node("LoadingIndicator")
			indicator.queue_free()