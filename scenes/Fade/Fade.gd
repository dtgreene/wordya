extends Node2D

enum States {
	HIDDEN,
	TRANSIT_TO_SHOW,
	SHOW,
	TRANSIT_TO_HIDDEN
}

var state = States.SHOW
var opacity = 1

func _process(delta):
	if state == States.TRANSIT_TO_SHOW:
		opacity += delta * 4

		if opacity >= 1:
			opacity = 1
			state = States.SHOW
			set_process(false)
	elif state == States.TRANSIT_TO_HIDDEN:
		opacity -= delta * 4
		
		if opacity <= 0:
			opacity = 0
			state = States.HIDDEN
			set_process(false)
			set_hidden(true)
	set_opacity(opacity)

func fade_out():
	set_process(true)
	state = States.TRANSIT_TO_HIDDEN

func fade_in():
	set_process(true)
	set_hidden(false)
	state = States.TRANSIT_TO_SHOW

func fade_out_now():
	state = States.HIDDEN
	opacity = 0
	set_opacity(opacity)

func fade_in_now():
	state = States.SHOW
	opacity = 1
	set_opacity(opacity)
	set_hidden(false)