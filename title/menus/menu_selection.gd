extends Node2D

onready var cursor = $Cursor
onready var animator = $AnimationPlayer

var current_menu
var current_menuitem : int = 0
onready var menus = [
	$Main,
	$Play,
	$HowToPlay,
	$Leaderboards
]

var is_cursor_disabled = false

signal play(grid_size, num_blocks, time, game_difficulty)
signal credits_pressed()
signal settings_pressed()
signal theme_select_pressed()

func _ready():	
	set_current_menu(0)
	$Main.connect("open_settings", self, "on_toggle_settings")
	$Main.connect("open_credits", self, "on_credits_open")
	$Main.connect("open_theme_select", self, "on_theme_select")
	
	for menu in menus:
		menu.connect("leaving", self, "_on_current_screen_leaving")
		menu.get_node("MenuOptions").connect("leave_tween_finished", self, "_on_finish_tween_out")
	menus[1].connect("play", self, "_on_play_button_clicked")
		
func on_credits_open():
	emit_signal("credits_pressed")
	
func on_theme_select():
	emit_signal("theme_select_pressed")
	
func on_toggle_settings():
	emit_signal("settings_pressed")

func _on_play_button_clicked(grid_size, tile_size, time, game_difficulty):
	emit_signal("play", grid_size, tile_size, time, game_difficulty)
	
func set_current_menu(index: int):
	current_menu = menus[index]
	current_menu.all_enter()
	update_cursor(0)
	
func set_cursor_position(offset: int):
	cursor.position = Vector2(10, 535 + 60 * offset)
	current_menuitem = offset
	
func update_cursor(index: int):
	if !is_cursor_disabled:
		set_cursor_position(index)
		current_menu._on_menuitem_hover(current_menuitem)
	
func _on_current_screen_leaving():
	animator.play("cursor_fade_out")
	
func _on_finish_tween_out():
	set_current_menu(current_menu.next_menu)
	animator.play("cursor_fade_in")
	
func is_mouse_over_label(pos: Vector2):
	pos.x = int(pos.x)
	pos.y = int(pos.y)
	if pos.y > 540 and pos.y < 540 + 60 * current_menu.menu_options.labels.size():
		var item_index = (pos.y - 540) / 60
		var item_size = current_menu.menu_options.labels[item_index].label.rect_size
		if pos.x > 100 and pos.x < 100 + item_size.x:
			return int(item_index)
		
	return -1
	
	
func _input(event):
	if event.is_action_pressed("ui_up"):
		if current_menuitem > 0:
			update_cursor(current_menuitem - 1)
		else:
			update_cursor(current_menu.menu_options.size())
			
	elif event.is_action_pressed("ui_down"):
		if current_menuitem < current_menu.menu_options.size(): 
			update_cursor(current_menuitem + 1)
		else:
			update_cursor(0)
			
	elif event.is_action_pressed("ui_accept"):
		if !current_menu.menu_options.labels[current_menuitem].tween.is_active():
			if !is_cursor_disabled:
				current_menu._on_menuitem_confirm(current_menuitem)
	
	if event is InputEventMouseMotion:
		var label_hovered = is_mouse_over_label(event.position)
		if label_hovered != -1:
			update_cursor(label_hovered)
			
	elif event is InputEventMouseButton:
		if !current_menu.menu_options.labels[current_menuitem].tween.is_active():
			if event.button_index == BUTTON_LEFT and event.pressed:
				var label_hovered = is_mouse_over_label(event.position)
				if label_hovered != -1 and (!is_cursor_disabled or label_hovered == 3):
					current_menu._on_menuitem_confirm(label_hovered)
