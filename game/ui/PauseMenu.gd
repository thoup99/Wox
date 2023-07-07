extends Control

var selected = 0
onready var options = [
	$"%Resume",
	$"%Restart",
	$"%GiveUp",
	$"%Mute",
	$"%ExitToMenu",
	$"%Quit"
]

signal resume
signal restart
signal give_up
signal mute(label, label_bold)
signal exit_to_menu
signal quit


var height = 60
var width = 300

var top_left = Vector2.ZERO
var bot_right = Vector2.ZERO
var divide_by = 0

var is_active = false

func _ready():
	#Center options around center of screen
	var mid_height = 540
	var mid_width = 960
	
	var space_between = 20
	var size = options.size()
	var start
	
	if size %  2 == 0:
		#Even
		var extra = size - 2
		start = mid_height - (space_between / 2) - (height / 2) - extra / 2 * (space_between + height)
		
	else:
		#Odd
		start = mid_height - (size - 1) / 2 * (height + space_between)
	
	for x in range(size):
			var offset = x * (height + space_between)
			options[x].position = Vector2(mid_width, start + offset)
			
	bold_selected()
	
	top_left = Vector2(mid_width - 150, start - 20)
	bot_right = Vector2(mid_width + 150, mid_height - start + mid_height + 20)
	divide_by = int((bot_right.y - top_left.y) / size) + 1
	
func is_point_in(pos: Vector2):
	if pos.x > top_left.x and pos.x < bot_right.x:
		if pos.y > top_left.y and pos.y < bot_right.y:
			return true
	return false
	
func set_selected(new: int):
	if selected == new:
		return
		
	unbold_selected()
	selected = new
	bold_selected()

func bold_selected():
	options[selected].get_node("Label").visible = false
	options[selected].get_node("LabelBold"). visible = true
	
func unbold_selected():
	options[selected].get_node("Label").visible = true
	options[selected].get_node("LabelBold"). visible = false
	
func emit():
	if selected == 0:
		emit_signal("resume")
	elif selected == 1:
		emit_signal("restart")
	elif selected == 2:
		emit_signal("give_up")
	elif selected == 3:
		emit_signal("mute", $Mute/Label, $Mute/LabelBold)
	elif selected == 4:
		emit_signal("exit_to_menu")
	elif selected == 5:
		emit_signal("quit")
		
	SfxManager.play("res://game/assets/sound/ui_accept.ogg")

func _input(event):
	if is_active:
		if event.is_action_pressed("ui_up"):
			var temp = selected - 1
			if temp < 0:
				temp += options.size()
			set_selected(temp)
			
		if event.is_action_pressed("ui_down"):
			set_selected((selected + 1) % options.size())
			
		if event is InputEventMouseMotion:
			if is_point_in(get_viewport().get_mouse_position()):
				set_selected(int((get_viewport().get_mouse_position().y - top_left.y) / divide_by))
		
		if event.is_action_pressed("ui_accept"):
			emit()
			
		if event.is_action_pressed("left_click"):
			if is_point_in(get_viewport().get_mouse_position()):
				emit()
