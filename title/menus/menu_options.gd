extends Node

export var options : PoolStringArray

onready var moveable_label = preload("res://title/menus/MoveableLabel.tscn")

var labels = []

var in_scene = false

signal leave_tween_finished()

func _ready():
	for i in range(0, options.size()):
		var new_label = moveable_label.instance()
		add_child(new_label)
		labels.append(new_label)
		new_label.set_start_position(Vector2(100, 540 + 60 * i))
		new_label.position = Vector2(100, 1080)
		new_label.get_node("Label").text = options[i]
		
		if (i == 0):
			labels[0].get_node("Tween").connect("tween_completed", self, "_on_tween_finished")
		
		
func _on_tween_finished(_object, _key):
	if !in_scene:
		emit_signal("leave_tween_finished")
	
func all_leave():
	in_scene = false
	for label in labels:
		label.leave()
	
func all_enter():
	in_scene = true
	for label in labels:
		label.enter()

func size():
	return labels.size() -1
