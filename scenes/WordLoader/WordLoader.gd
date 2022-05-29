extends Node2D

const Poppins = preload("res://assets/Fonts/Poppins32.fnt")

var file = File.new()
var words = []

export var file_path = ""

signal words_loaded(words)

func _ready():
	file.open(file_path, File.READ)
	set_process(true)

func _process(delta):
	var used_line = ""
	var lines_read = 0
	
	# append each word to our array
	while lines_read < 1000:
		used_line = file.get_line()
		lines_read += 1
		if used_line.length() > 0:
			words.append(used_line)
		else:
			break
	
	if file.eof_reached():
		file.close()
		set_process(false)
		emit_signal("words_loaded", words)