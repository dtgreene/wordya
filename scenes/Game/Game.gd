extends "res://scenes/Transition/Transition.gd"

const Constants = preload("res://scenes/Constants/Constants.gd")

const online_file_path = "user://online_progress.json"
const offline_file_path = "user://offline_progress.json"

onready var input_release = get_node("/root/Main/InputRelease")
onready var effects_player = get_node("/root/Main/EffectsPlayer")

onready var keyboard = get_node("Keyboard")
onready var guess_grid = get_node("GuessGrid")
onready var prompts = get_node("Prompts")
onready var status_modal = get_node("StatusModal")

var target_word = ""
var offline_words = []
var game_progress = null
var offline_game = false
var modal_visible = false

signal stop_game()
signal guess_result(result)

func _ready():
	get_node("WordLoader").connect("words_loaded", self, "on_offline_words_loaded")
	
	transit_items.append(TransitItem.new(self, Vector2(), Vector2(0, 720)))
	hide_now()
	
	prompts.fade_out_now()
	
	set_process(true)
	
	guess_grid.connect("evaluate_game", self, "on_evaluate_game")
	
	keyboard.connect("key_input", guess_grid, "on_key_input")
	keyboard.connect("key_delete", guess_grid, "on_key_delete")

func _process(delta):
	if state == States.SHOW:
		if modal_visible:
			if input_release.is_action_just_pressed("select"):
				hide_status_modal()
			if offline_game && input_release.is_action_just_pressed("submit"):
				new_offline_word()
		elif input_release.is_action_just_pressed("ui_cancel"):
			effects_player.play("ui_back")
			emit_signal("stop_game")

func init(word = ""):
	if word.length() == 5:
		offline_game = false
		target_word = word
		# get existing online progress if the word matches
		game_progress = get_online_progress(target_word)
	else:
		offline_game = true
		# get existing offline progress
		game_progress = get_offline_progress()
		if game_progress != null:
			target_word = game_progress.word
		else:
			# get an offline word
			var index = floor(rand_range(0, offline_words.size()))
			target_word = offline_words[index].to_upper()
			
			game_progress = GameProgress.new(target_word, offline_file_path)
	
	guess_grid.set_progress(game_progress)
	keyboard.set_progress(game_progress)

func new_offline_word():
	hide_status_modal()
	
	var directory = Directory.new()
	var file = File.new()
	if file.file_exists(offline_file_path):
		directory.remove(offline_file_path)
	
	game_progress = null
	
	guess_grid.reset()
	keyboard.reset()
	
	guess_grid.enable()
	keyboard.enable()
	
	init()
	on_evaluate_game()

func guess_word(word):
	var result = []
	result.resize(5)
	
	# build word dictionary
	var available_letters = {}
	var i = 0
	while i < 5:
		if available_letters.has(target_word[i]):
			available_letters[target_word[i]] += 1
		else:
			available_letters[target_word[i]] = 1
		i += 1
	
	# make correct letter pass
	i = 0
	while i < 5:
		if word[i] == target_word[i]:
			# letter found in the right spot
			result[i] = Constants.GuessResults.CORRECT
			available_letters[word[i]] -= 1
		else:
			result[i] = Constants.GuessResults.NOT_FOUND
		i += 1
	
	i = 0
	while i < 5:
		if target_word.find(word[i]) > -1 && available_letters[word[i]] > 0:
			# letter found but not in the right spot
			result[i] = Constants.GuessResults.WRONG_POSITION
			available_letters[word[i]] -= 1
		i += 1
	
	game_progress.add_guess_word(word)
	game_progress.add_guess_result(result)
	game_progress.save()
	
	return result

func on_offline_words_loaded(words):
	Globals.set("offline_words_ready", true)
	offline_words = words

func on_hide_start():
	prompts.fade_out()
	status_modal.fade_out()
	
	guess_grid.disable()
	keyboard.disable()
	
	guess_grid.reset()
	keyboard.reset()

func on_hide_end():
	set_hidden(true)

func on_show_start():
	set_hidden(false)

func on_show_end():
	prompts.fade_in()
	
	guess_grid.enable()
	keyboard.enable()
	
	on_evaluate_game()

func on_evaluate_game():
	if game_progress == null: return
	
	var winner = game_progress.guess_words.find(target_word) > -1
	var game_over = game_progress.guess_words.size() >= 5 || winner
	if game_over:
		var result = Constants.GameResults.NONE
		if offline_game:
			if winner:
				result = Constants.GameResults.WIN_OFFLINE
			else:
				result = Constants.GameResults.LOSE_OFFLINE
		else:
			if winner:
				result = Constants.GameResults.WIN_ONLINE
			else:
				result = Constants.GameResults.LOSE_ONLINE
		
		guess_grid.disable()
		keyboard.disable()
		
		status_modal.set_game_result(result, game_progress)
		show_status_modal()

func get_online_progress(word):
	var save_data = read_save_file(online_file_path)
	var progress = GameProgress.new(word, online_file_path)
	
	if save_data != null && save_data.word == word:
		progress.guess_words = save_data.guess_words
		progress.guess_results = save_data.guess_results

	return progress

func get_offline_progress():
	var save_data = read_save_file(offline_file_path)
	var progress = null
	
	if save_data != null:
		progress = GameProgress.new(save_data.word, offline_file_path)
		progress.guess_words = save_data.guess_words
		progress.guess_results = save_data.guess_results
	
	return progress

func show_status_modal():
	status_modal.fade_in()
	modal_visible = true
	effects_player.play("swoosh")

func hide_status_modal():
	status_modal.fade_out()
	modal_visible = false
	effects_player.play("success")

func read_save_file(file_path):
	var file = File.new()
	if file.file_exists(file_path):
		file.open(file_path, File.READ)
		var data = {}
		data.parse_json(file.get_as_text())
		file.close()
		
		if (
			data.has("word") && 
			data.has("guess_words") && 
			data.has("guess_results") && 
			data.word.length() == 5 && 
			data.guess_words.size() <= 5 && 
			data.guess_results.size() <= 5 &&
			data.guess_words.size() == data.guess_results.size()
		):
			return data
		
	return null

class GameProgress:
	var word = ""
	var guess_words = []
	var guess_results = []
	var file_path = ""
	var directory = Directory.new()

	func _init(_word, _file_path):
		word = _word
		file_path = _file_path
		
	func add_guess_word(value):
		guess_words.append(value)
	
	func add_guess_result(value):
		guess_results.append(value)
	
	func save():
		var data = {
			word = word,
			guess_words = guess_words,
			guess_results = guess_results
		}
		
		# sanity check
		if guess_words.size() > 5:
			guess_words.resize(5)
		
		# sanity check
		if guess_results.size() > 5:
			guess_results.resize(5)
		
		var file = File.new()
		if !file.file_exists(file_path):
			directory.remove(file_path)
		file.open(file_path, File.WRITE)
			
		file.store_string(data.to_json())
		file.close()