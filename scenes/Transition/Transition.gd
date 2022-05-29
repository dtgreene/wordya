extends Node2D

enum States {
	HIDDEN,
	TRANSIT_TO_SHOW,
	SHOW,
	TRANSIT_TO_HIDDEN
}

var state = States.SHOW
var transit_frames = 0
var transit_items = []

func _process(delta):
	if state == States.TRANSIT_TO_SHOW:
		transit_frames += 1
		
		for item in transit_items:
			item.transit_pos = item.transit_pos + item.delta_pos * delta
			item.instance.set_pos(item.transit_pos)
		
		if transit_frames >= 60:
			state = States.SHOW
			transit_frames = 0
			
			for item in transit_items:
				item.transit_pos = item.show_pos
				item.instance.set_pos(item.transit_pos)
			
			on_show_end()
			
	elif state == States.TRANSIT_TO_HIDDEN:
		transit_frames += 1
		
		for item in transit_items:
			item.transit_pos = item.transit_pos + item.delta_pos * -delta
			item.instance.set_pos(item.transit_pos)
		
		if transit_frames >= 60:
			state = States.HIDDEN
			transit_frames = 0
			
			for item in transit_items:
				item.transit_pos = item.hide_pos
				item.instance.set_pos(item.transit_pos)
			
			on_hide_end()

func hide():
	if state != States.SHOW: return
	
	on_hide_start()
	state = States.TRANSIT_TO_HIDDEN

func show():
	if state != States.HIDDEN: return
	
	on_show_start()
	state = States.TRANSIT_TO_SHOW

func hide_now():
	on_hide_start()
	on_hide_end()
	
	state = States.HIDDEN
	transit_frames = 0
	
	for item in transit_items:
		item.transit_pos = item.hide_pos
		item.instance.set_pos(item.transit_pos)

func show_now():
	on_show_start()
	on_show_end()
	
	state = States.SHOW
	transit_frames = 0
	
	for item in transit_items:
		item.transit_pos = item.show_pos
		item.instance.set_pos(item.transit_pos)

func on_hide_start():
	pass

func on_hide_end():
	pass

func on_show_start():
	pass

func on_show_end():
	pass

class TransitItem:
	var instance = null
	var show_pos = null
	var hide_pos = null
	var delta_pos = null
	var transit_pos = null
	func _init(_instance, _show_pos, _hide_pos):
		instance = _instance
		show_pos = _show_pos
		hide_pos = _hide_pos
		
		delta_pos = show_pos - hide_pos
		transit_pos = show_pos

