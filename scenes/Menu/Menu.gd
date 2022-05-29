extends "res://scenes/Transition/Transition.gd"

onready var input_release = get_node("/root/Main/InputRelease")
onready var effects_player = get_node("/root/Main/EffectsPlayer")

onready var banner_label = get_node("BannerLabel")
onready var status_label = get_node("StatusLabel")
onready var online_button = get_node("Buttons/OnlineButton")
onready var offline_button = get_node("Buttons/OfflineButton")
onready var http_request = get_node("HTTPRequest")
onready var buttons = get_node("Buttons")

var active_button = 0
var online_word = ""
var loading = false

signal start_game(word)

func _ready():
	transit_items.append(TransitItem.new(banner_label, Vector2(0, 250), Vector2(0, 15)))
	transit_items.append(TransitItem.new(buttons, Vector2(0, 0), Vector2(0, -235)))
	
	set_process(true)
	online_button.set_active(true)
	
	http_request.connect("request_completed", self, "on_http_request_completed")

func _process(delta):
	if state == States.SHOW:
		if loading: return
		
		if input_release.is_action_just_pressed("ui_up"):
			increment_button(-1)
		elif input_release.is_action_just_pressed("ui_down"):
			increment_button(1)
		
		if input_release.is_action_just_pressed("select"):
			effects_player.play("ui_select")
			if active_button == 0:
				loading = true
				http_request.request("http://wordya-public.s3.amazonaws.com/daily-word.json")
				online_button.set_loading(true)
			elif active_button == 1:
				emit_signal("start_game", "")

func on_hide_start():
	status_label.set_text("")
	status_label.set_hidden(true)
	
	buttons.fade_out()

func on_hide_end():
	set_process(false)

func on_show_start():
	status_label.set_text("")
	status_label.set_hidden(false)
	
	set_process(true)

func on_show_end():
	active_button = 0
	online_button.set_active(true)
	offline_button.set_active(false)
	
	buttons.fade_in()
	
	status_label.set_text("")
	status_label.set_hidden(false)

func increment_button(amount):
	effects_player.play("ui_move")
	
	active_button += amount
	
	if active_button > 1:
		active_button = 0
	elif active_button < 0:
		active_button = 1
	
	if active_button == 0:
		online_button.set_active(true)
		offline_button.set_active(false)
	elif active_button == 1:
		online_button.set_active(false)
		offline_button.set_active(true)

func on_http_request_completed(result, response_code, headers, body):
	if result == 0 && response_code == 200:
		var data = {}
		data.parse_json(body.get_string_from_utf8())
		online_word = data.word.to_upper()
		status_label.set_text("")
		
		emit_signal("start_game", online_word)
	else:
		status_label.set_text("Failed to get word of the day")
		online_word = ""
	
	loading = false
	online_button.set_loading(false)
