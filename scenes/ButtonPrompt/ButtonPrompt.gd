extends Node2D

const Poppins = preload("res://assets/Fonts/Poppins32.fnt")
const Icons = preload("res://assets/Images/icons.png")

const size = Vector2(64, 64)

export var text = ""
export var icon_index = 0

func _draw():
	draw_texture_rect_region(Icons, Rect2(Vector2(), size), Rect2(Vector2(icon_index * 64, 0), size))
	draw_string(Poppins, Vector2(64, 42), text)