extends Node2D


onready var cursor = $"."

onready var closed_sprite = $CursorClosed
onready var open_sprite = $CursorOpen

var is_controller = false
var is_button_down = false
var paused = false

var velocity: Vector2

signal hiding()
signal showing()


func _input(event):
	if !paused:
		if event is InputEventMouseMotion:
			hide_cursor()
		elif event is InputEventJoypadMotion and (event.axis == 0 or event.axis == 1):
			if abs(event.axis_value) > 0.5:
				show_cursor()
				
		elif event.is_action_pressed("left_click"):
			closed_sprite.show()
			open_sprite.hide()
			CursorData.is_closed = true
		elif event.is_action_released("left_click"):
			closed_sprite.hide()
			open_sprite.show()
			CursorData.is_closed = false
			
func hide_cursor():
	if is_controller:
		is_controller = false
		visible = false
		Input.warp_mouse_position(cursor.position)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		CursorData.is_active = false
		emit_signal("hiding")
	
func show_cursor():
	if !is_controller:
		is_controller = true
		visible = true
		position = get_viewport().get_mouse_position()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		CursorData.is_active = true
		emit_signal("showing")
		
func _physics_process(delta):
	if !paused and is_controller:
		move(delta)
		CursorData.position = position

func move(delta):
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	cursor.position.x += velocity.x * 100 * SettingsSystem.game_data["controller_x"] * delta
	cursor.position.y += velocity.y * 100 * SettingsSystem.game_data["controller_y"] * delta
	if cursor.position.x < 0: cursor.position.x = 0
	if cursor.position.x > 1920: cursor.position.x = 1920
	if cursor.position.y < 0: cursor.position.y = 0
	if cursor.position.y > 1080: cursor.position.y = 1080
