extends Node

onready var input_release = get_node("InputRelease")
onready var menu = get_node("Menu")
onready var game = get_node("Game")

func _ready():
	Globals.set("offline_words_ready", false)
	Globals.set("all_words_ready", false)
	
	randomize()
	
	menu.connect("start_game", self, "on_start_game")
	game.connect("stop_game", self, "on_stop_game")
	
	input_release.add_input_actions([
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down",
		"ui_cancel",
		"select",
		"submit",
		"delete"
	])

func on_start_game(word):
	# not ready yet
	if !Globals.get("offline_words_ready") || !Globals.get("all_words_ready"): return
	
	menu.hide()
	
	if word.length() == 5:
		game.init(word)
	else:
		game.init()
	
	game.show()
	
func on_stop_game():
	menu.show()
	game.hide()