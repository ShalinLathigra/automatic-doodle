extends Control

func _input(event):
	if event.is_action_pressed("skip_move"):
		get_tree().change_scene("res://Scenes/Tester.tscn")

func _ready():
	var text = ""
	text += "Turns Taken: " + String(Stats.moves) + "\n"
	text += "Violence Partaken: " + String(Stats.kills) + "\n"
	var total_ms = OS.get_ticks_msec() - Stats.start_time
	var s = total_ms / 1000.0
	var m = floor(s / 60.0)
	var s_rem = s - m * 60
	var m_text = String(int(m))
	if m_text.length() < 2:
		m_text = "0" + m_text
	var s_text = String(int(s_rem))
	if s_text.length() < 2:
		s_text = "0" + s_text
	text += "Time Taken: " + m_text  + ":" + s_text + "\n"
	$Stats.text = text
	
func _process(_delta):
	if Input.is_action_pressed("shove_left") or Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left"):
		$Stats.modulate.a = 0
		$Credits.modulate.a = 1
	else:
		$Stats.modulate.a = 1
		$Credits.modulate.a = 0
