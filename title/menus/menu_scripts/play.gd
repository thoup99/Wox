extends Node

onready var menu_options = $MenuOptions
var next_menu = 0

signal leaving
signal play(grid_size, num_blocks, time, game_difficulty)

func _ready():
	if !SaveSystem.is_unlocked("Normal"):
		menu_options.labels[2].set_color("Gray")
	if !SaveSystem.is_unlocked("Hard"):
		menu_options.labels[3].set_color("Gray")
	if !SaveSystem.is_unlocked("Extreme"):
		menu_options.labels[4].set_color("Gray")
		
	#menu_options.labels[5].set_color("Gray")

func _on_menuitem_hover(_i: int):
	pass
	
func _on_menuitem_confirm(i: int):
	match(i):
		0:
			emit_signal("play", 20, 6, 600, "Beginner")
		1:
			emit_signal("play", 20, 5, 480, "Easy")
		2:
			if SaveSystem.is_unlocked("Normal"):
				emit_signal("play", 18, 4, 420, "Normal")
		3:
			if SaveSystem.is_unlocked("Hard"):
				emit_signal("play", 16, 3, 360, "Hard")
		4:
			if SaveSystem.is_unlocked("Extreme"):
				emit_signal("play", 14, 2, 270, "Extreme")
		5:
			emit_signal("leaving")
			all_leave()
			next_menu = 0
		
func all_enter():
	menu_options.all_enter()
	
func all_leave():
	menu_options.all_leave()
