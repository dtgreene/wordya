extends "res://scenes/Fade/Fade.gd"

const guess_count_words = [
	"INSANE",
	"AWESOME",
	"NICE",
	"DECENT",
	"OKAY"
]

const Constants = preload("res://scenes/Constants/Constants.gd")
const LabelScene = preload("res://scenes/StatusModal/StatusLabel.tscn")
const ButtonScene = preload("res://scenes/ButtonPrompt/ButtonPrompt.tscn")

const backdrop_size = Vector2(1280, 720)
const backdrop_color = Color("111111")

var result = Constants.GameResults.NONE

signal dismiss()

func _ready():
	fade_out_now()

func _draw():
	draw_rect(Rect2(Vector2(), backdrop_size), backdrop_color)
	
	# draw_rect(Rect2(Vector2(383, 103), Vector2(514, 514)), Color("555555"))
	# draw_rect(Rect2(Vector2(384, 104), Vector2(512, 512)), Color())
	
	if result == Constants.GameResults.NONE: return

func set_game_result(_result, game_progress):
	result = _result
	
	for child in get_children():
		child.queue_free()
	
	var labels = []
	var word_label = StatusLabel.new("The word was", game_progress.word)
	
	if result == Constants.GameResults.WIN_OFFLINE || result == Constants.GameResults.WIN_ONLINE:
		var guess_count = game_progress.guess_words.size()
		labels.append(StatusLabel.new("Your guess count was " + str(guess_count), guess_count_words[guess_count - 1]))
	else:
		labels.append(StatusLabel.new("Better luck next time...", ""))
	
	labels.append(word_label)
	
	var dismiss_button = ButtonScene.instance()
	dismiss_button.text = "Dismiss"
	dismiss_button.icon_index = 1
	add_child(dismiss_button)
	
	if result == Constants.GameResults.WIN_ONLINE || result == Constants.GameResults.LOSE_ONLINE:
		var minutes_left = get_minutes_to_next_word()
		var hours = floor(minutes_left / 60)
		var minutes = minutes_left % 60
		labels.append(StatusLabel.new("Time until next word", str(hours) + "h" + " " + str(minutes) + "m"))
	else:
		var word_button = ButtonScene.instance()
		word_button.set_pos(Vector2(0, 56))
		word_button.text = "New Word"
		word_button.icon_index = 3
		add_child(word_button)
	
	create_labels(labels)

func create_labels(labels):
	var y = 360 - (labels.size() * 48)
	var used_instance = null
	for label in labels:
		used_instance = LabelScene.instance()
		used_instance.set_text(label.label_text)
		used_instance.get_node("StatusTextLabel").set_text(label.value_text)
		used_instance.set_pos(Vector2(320, y))
		add_child(used_instance)
		y += 96

func get_minutes_to_next_word():
	var time = OS.get_time(true)
	var minutes = 0
	if time.hour < 6:
		# time until 6
		minutes = (6 - time.hour) * 60
	else:
		# time until 6
		minutes = (24 - time.hour + 6) * 60
	
	minutes -= time.minute
	
	return minutes

class StatusLabel:
	var label_text = ""
	var value_text = ""
	func _init(_label_text, _value_text):
		label_text = _label_text
		value_text = _value_text