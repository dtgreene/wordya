extends Node2D

const KeyInstance = preload("res://scenes/Keyboard/Key.tscn")

const origin_x = 1280 * 0.5
const origin_y = 512
const key_margin = 4
const key_size = 40 + key_margin * 2

const top_letters = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
const mid_letters = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
const low_letters = ["Z", "X", "C", "V", "B", "N", "M"]

onready var effects_player = get_node("/root/Main/EffectsPlayer")
onready var input_release = get_node("/root/Main/InputRelease")

var keys = {}
var active_key = "Q"
var active_row = 0
var active_col = 0

signal key_input(key)
signal key_delete()

func _ready():
	add_letters(top_letters, 0)
	add_letters(mid_letters, key_size)
	add_letters(low_letters, key_size * 2)
	
	keys[active_key].set_active(true)

func _process(delta):
	if input_release.is_action_just_pressed("ui_left"):
		increment_col(-1)
	elif input_release.is_action_just_pressed("ui_right"):
		increment_col(1)
	
	if input_release.is_action_just_pressed("ui_up"):
		increment_row(-1)
	elif input_release.is_action_just_pressed("ui_down"):
		increment_row(1)
	
	if input_release.is_action_just_pressed("select"):
		var key = ""
		if active_row == 0:
			key = top_letters[active_col]
		elif active_row == 1:
			key = mid_letters[active_col]
		elif active_row == 2:
			key = low_letters[active_col]
		emit_signal("key_input", key)
	
	if input_release.is_action_just_pressed("delete"):
		emit_signal("key_delete")

func set_progress(progress):
	# word, guess_results, guess_words
	var guess_words = progress.guess_words
	var guess_results = progress.guess_results
	
	var i = 0
	while i < guess_words.size():
		var j = 0
		var word = guess_words[i]
		var result = guess_results[i]
		while j < word.length():
			set_result(word[j], result[j])
			j += 1
		i += 1

func reset():
	for key in keys.keys():
		keys[key].reset()
	
	active_key = "Q"
	keys[active_key].set_active(true)
	active_row = 0
	active_col = 0

func set_result(key, value):
	keys[key].set_result(value)

func enable():
	set_process(true)

func disable():
	set_process(false)

func increment_col(amount):
	active_col += amount
	
	# determine max index for col
	var max_col = 0
	if active_row == 0:
		max_col = top_letters.size() - 1
	elif active_row == 1:
		max_col = mid_letters.size() - 1
	elif active_row == 2:
		max_col = low_letters.size() - 1
	# wrap col
	if active_col < 0:
		active_col = max_col
	elif active_col > max_col:
		active_col = 0
	
	activate_key()

func increment_row(amount):
	var old_row = active_row
	
	active_row += amount
	
	# wrap row
	if active_row < 0:
		active_row = 2
	elif active_row > 2:
		active_row = 0
	
	# row-specific logic
	if old_row == 2 && (active_row == 1 || active_row == 0):
		active_col += 1
	elif active_row == 2 && (old_row == 0 || old_row == 1):
		active_col -= 1
	
	# fix col if the new row isn't long enough
	var max_col = 0
	if active_row == 0:
		max_col = top_letters.size() - 1
	elif active_row == 1:
		max_col = mid_letters.size() - 1
	elif active_row == 2:
		max_col = low_letters.size() - 1
	# wrap col
	if active_col < 0:
		active_col = 0
	elif active_col > max_col:
		active_col = max_col
	
	activate_key()


func activate_key():
	effects_player.play("ui_move")
	
	# de-activate current key
	keys[active_key].set_active(false)
	
	if active_row == 0:
		active_key = top_letters[active_col]
	elif active_row == 1:
		active_key = mid_letters[active_col]
	elif active_row == 2:
		active_key = low_letters[active_col]
	
	# activate new key
	keys[active_key].set_active(true)

func add_letters(letters, y_offset):
	var row_width = letters.size() * key_size
	var row_height = key_size * 0.5
	
	var start_x = origin_x - row_width * 0.5
	var start_y = origin_y - row_height * 0.5 + y_offset
	
	var used_instance
	var used_letter
	for i in range(letters.size()):
		used_instance = KeyInstance.instance()
		used_instance.set_pos(Vector2(start_x + i * key_size, start_y))
		used_letter = letters[i]
		used_instance.set_letter(used_letter)
		keys[used_letter] = used_instance
		add_child(used_instance)

