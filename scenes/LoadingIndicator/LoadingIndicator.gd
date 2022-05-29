extends Node2D

const point_radius = 4
const point_color = Color(1, 1, 1)
const sin_speed = 0.1
const sin_height = 8

var points = []

func _ready():
	var i = 0
	var used_point
	var canvas_item = get_canvas_item()
	var x_offset = -3 * 12 * 0.5
	while i < 3:
		used_point = Point.new(Vector2(x_offset + i * 12, 0), canvas_item, i * PI)
		points.append(used_point)
		i += 1
	
	set_process(true)

func _process(delta):
	var i = 0
	while i < 3:
		points[i].update()
		i += 1

class Point:
	var pos = Vector2(rand_range(0, 1280), rand_range(0, 720))
	var rid = null
	var sin_value = 0
	
	func _init(_pos, canvas_item, sin_offset):
		pos = _pos
		
		rid = VisualServer.canvas_item_create()
		VisualServer.canvas_item_set_parent(rid, canvas_item)
		VisualServer.canvas_item_add_circle(rid, Vector2(), point_radius, point_color)
		var matrix = Matrix32(0, pos)
		VisualServer.canvas_item_set_transform(rid, matrix)
		
		sin_value = sin_offset
	
	func update():
		sin_value += sin_speed
		
		var sin_pos = Vector2(0, sin(sin_value) * sin_height)
		
		var matrix = Matrix32(0, pos + sin_pos)
		VisualServer.canvas_item_set_transform(rid, matrix)