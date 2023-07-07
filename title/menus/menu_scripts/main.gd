extends Node

onready var menu_options = $MenuOptions
var next_menu = 0

signal leaving
signal open_settings
signal open_theme_select
signal open_credits

func swap_menu(next: int):
	emit_signal("leaving")
	all_leave()
	next_menu = next

func _on_menuitem_hover(_i: int):
	pass
	
func _on_menuitem_confirm(i: int):
	match(i):
		0:
			swap_menu(1)
		1:
			swap_menu(2)
		2:
			swap_menu(3)
		3:
			emit_signal("open_theme_select")
		4:
			emit_signal("open_settings")
		5:
			emit_signal("open_credits")
		6:
			get_tree().quit()
		
func all_enter():
	menu_options.all_enter()
	
func all_leave():
	menu_options.all_leave()
