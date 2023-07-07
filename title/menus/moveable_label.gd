extends Node2D

onready var tween = $Tween
onready var label = $Label

var start_position : Vector2
var end_position = Vector2(100, 1080)

func set_start_position(new_pos: Vector2):
	start_position = new_pos
	position = new_pos

func set_text(text: String):
	label.text = text

func leave():
	tween.interpolate_property($".", "position",
		start_position, Vector2(-400, start_position.y), 0.75,
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	tween.start()
	
func enter():
	tween.interpolate_property($".", "position",
		end_position, start_position, 1,
		Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	
func set_color(name: String):
	match(name):
		"White":
			label.modulate = Color(1, 1, 1)
		"Gray":
			label.modulate = Color(0.33, 0.33, 0.33)
		"Dark Gray":
			label.modulate = Color(0.39, 0.39, 0.39)
		_:
			print("Unrecognized color: "+name)
