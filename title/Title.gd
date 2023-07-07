extends Node

onready var menu_selection = $MenuSelection
onready var customization = $Customization
onready var background = $Background
onready var credits = $Credits
onready var settings = $Settings

func _input(event):
	if event.is_action_pressed("esc"):
		get_tree().quit()
		
func _on_Customization_theme_selected():
	background.load_video()
	

func customization_to_main():
	menu_selection.is_cursor_disabled = false
	customization.position = Vector2(0, 1100)
	menu_selection.position = Vector2(0, 0)

func main_to_customization():
	menu_selection.is_cursor_disabled = true
	menu_selection.position = Vector2(0, 1100)
	customization.position = Vector2(0, 0)
	
func main_to_credits():
	menu_selection.is_cursor_disabled = true
	menu_selection.position = Vector2(0, 1100)
	credits.position = Vector2(0,0)

func credits_to_main():
	menu_selection.is_cursor_disabled = false
	menu_selection.position = Vector2(0,0)
	credits.position = Vector2(0,1100)
	
func main_to_settings():
	menu_selection.is_cursor_disabled = true
	menu_selection.position = Vector2(0, 1100)
	settings.position = Vector2(0, 0)
	
func settings_to_main():
	menu_selection.is_cursor_disabled = false
	menu_selection.position = Vector2(0, 0)
	settings.position = Vector2(0, 1100)


func _on_Customization_exit_customization():
	customization_to_main()


func _on_Credits_credits_exit():
	credits_to_main()


func _on_MenuSelection_credits_pressed():
	main_to_credits()


func _on_MenuSelection_theme_select_pressed():
	main_to_customization()


func _on_MenuSelection_settings_pressed():
	main_to_settings()


func _on_Settings_exit():
	settings_to_main()
