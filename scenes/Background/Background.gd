extends Node2D

const two_pi = PI * 2
const min_speed = 0.5
const max_speed = 1.5
const point_color = Color("5539a7")
const point_count = 25
const point_distance = 256

var points = []
var lines_rid = null

func _ready():
	var i = 0
	var used_point
	var canvas_item = get_canvas_item()
	while i < point_count:
		used_point = Point.new(canvas_item)
		points.append(used_point)
		i += 1
	
	lines_rid = VisualServer.canvas_item_create()
	VisualServer.canvas_item_set_parent(lines_rid, canvas_item)
	
	set_fixed_process(true)

func _fixed_process(delta):
	var i = 0
	while i < point_count:
		points[i].update()
		i += 1
	
	points.sort_custom(self, "point_sort")
	
	# clear the previous frame's lines
	VisualServer.canvas_item_clear(lines_rid)
	
	i = 0
	var used_point_a
	var used_point_b
	while i < point_count:
		used_point_a = points[i]
		var j = i + 1
		while j < point_count:
			used_point_b = points[j]
			if abs(used_point_a.pos.y - used_point_b.pos.y) < point_distance:
				var d = used_point_a.pos.distance_to(used_point_b.pos)
				if d < point_distance:
					point_color.a = 1 - d / point_distance
					VisualServer.canvas_item_add_line(lines_rid, used_point_a.pos, used_point_b.pos, point_color)
					point_color.a = 1
			else: break
			j += 1
		i += 1

func point_sort(a, b):
	return a.pos.y - b.pos.y < 0

class Point:
	var pos = Vector2(rand_range(0, 1280), rand_range(0, 720))
	var acc = Vector2()
	var rid = null
	func _init(canvas_item):
		var radius = rand_range(1, 3)
		
		rid = VisualServer.canvas_item_create()
		VisualServer.canvas_item_set_parent(rid, canvas_item)
		VisualServer.canvas_item_add_circle(rid, Vector2(), radius, point_color)
		var matrix = Matrix32(0, pos)
		VisualServer.canvas_item_set_transform(rid, matrix)
		
		var direction = rand_range(0, two_pi)
		var speed = rand_range(min_speed, max_speed)
		
		acc.x = cos(direction) * speed
		acc.y = sin(direction) * speed
	
	func update():
		if pos.x + acc.x < 0 || pos.x + acc.x > 1280:
			acc.x *= -1
		if pos.y + acc.y < 0 || pos.y + acc.y > 720:
			acc.y *= -1
		
		pos.x += acc.x
		pos.y += acc.y
		
		var matrix = Matrix32(0, pos)
		VisualServer.canvas_item_set_transform(rid, matrix)
