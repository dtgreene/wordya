extends Node2D

const Constants = preload("res://scenes/Constants/Constants.gd")
const CellScene = preload("res://scenes/GuessGrid/Cell.tscn")

enum States {
	INPUT,
	EVALUATING_GUESS,
	DISABLED
}

onready var effects_player = get_node("/root/Main/EffectsPlayer")
onready var input_release = get_node("/root/Main/InputRelease")
onready var toast = get_node("/root/Main/Game/Toast")
onready var keyboard = get_node("/root/Main/Game/Keyboard")
onready var game = get_parent()

var cells = []
var active_col = 0
var active_row = 0
var all_words = []
var current_word = ""
var state = States.INPUT
var guess_result = []
var result_frames = 0
var result_index = 0

signal guess_word(word)
signal evaluate_game()

func _ready():
	get_node("WordLoader").connect("words_loaded", self, "on_all_words_loaded")
	
	var origin_x = 1280 * 0.5
	var origin_y = 280
	
	var cell_margin = 4
	var cell_size = 64 + cell_margin * 2
	var grid_size = 5 * cell_size
	
	var start_x = origin_x - grid_size * 0.5
	var start_y = origin_y - grid_size * 0.5
	
	var used_instance
	for y in range(5):
		var cols = []
		for x in range(5):
			used_instance = CellScene.instance()
			used_instance.set_pos(Vector2(start_x + x * cell_size, start_y + y * cell_size))
			cols.append(used_instance)
			add_child(used_instance)
		cells.append(cols)

func _process(delta):
	if state == States.EVALUATING_GUESS:
		if result_frames <= 0:
			result_frames = 0.5
			
			cells[active_row][result_index].set_result(guess_result[result_index])
			keyboard.set_result(current_word[result_index], guess_result[result_index])
			
			result_index += 1
			
			if result_index >= 5:
				active_col = 0
				active_row += 1
				
				current_word = ""
				
				emit_signal("evaluate_game")
				
				if active_row >= 5:
					state = States.DISABLED
				else:
					state = States.INPUT
		else:
			result_frames -= delta
	
	if state != States.INPUT: return
	
	if input_release.is_action_just_pressed("submit"):
		if current_word.length() < 5:
			toast.show_toast("Not enough letters")
			shake_current_row()
		elif all_words.find(current_word.to_lower()) == -1:
			toast.show_toast("Unknown word")
			shake_current_row()
		else:
			guess_result = game.guess_word(current_word)
			result_frames = 0
			result_index = 0
			state = States.EVALUATING_GUESS

func on_all_words_loaded(words):
	Globals.set("all_words_ready", true)
	all_words = words

func shake_current_row():
	cells[active_row][0].shake()
	cells[active_row][1].shake()
	cells[active_row][2].shake()
	cells[active_row][3].shake()
	cells[active_row][4].shake()

func set_progress(progress):
	# word, guess_results, guess_words
	var guess_words = progress.guess_words
	var guess_results = progress.guess_results
	
	var i = 0
	while i < guess_words.size():
		var j = 0
		var word = guess_words[i]
		var result = guess_results[i]
		var used_cell = null
		while j < word.length():
			used_cell = cells[i][j]
			used_cell.set_text(word[j])
			used_cell.set_result(result[j])
			j += 1
		i += 1
	
	active_row = i
	
	if active_row >= 5:
		state = States.DISABLED

func reset():
	active_row = 0
	active_col = 0
	current_word = ""
	state = States.INPUT
	guess_result = []
	result_frames = 0
	result_index = 0
	
	for y in range(5):
		for x in range(5):
			cells[y][x].reset()

func enable():
	set_process(true)

func disable():
	set_process(false)

func on_key_input(key):
	if state != States.INPUT: return
	
	if active_col < 5:
		effects_player.play("ui_select")
		cells[active_row][active_col].set_text(key)
		active_col += 1
		current_word += key

func on_key_delete():
	if state != States.INPUT: return
	
	var prev_col = active_col - 1
	if prev_col >= 0:
		effects_player.play("delete")
		cells[active_row][prev_col].set_text("")
		active_col -= 1
		
		current_word = current_word.substr(0, current_word.length() - 1)