extends Node2D


var display_index = 0
onready var display_holder = $DisplayHolder
onready var display_1 = $DisplayHolder/Display1
onready var display_2 = $DisplayHolder/Display2

onready var select_label = $ButtonSelect/Label
var selected_theme = 0

var theme_index = 0
onready var themes = [
	{
		"name": "default",
		"texture": load("res://title/customization/assets/images/themes/default/default.png"),
		"unlocked": true
	},
	{
		"name": "jungle",
		"texture": load("res://title/customization/assets/images/themes/jungle/jungle.png"),
		"locked_texture": load("res://title/customization/assets/images/themes/jungle/jungle_grayscale.png"),
		"requirement": "Complete Easy Mode to Unlock This Background",
		"unlocked": SaveSystem.is_unlocked("Normal")
	},
	{
		"name": "castle",
		"texture": load("res://title/customization/assets/images/themes/castle/castle.png"),
		"locked_texture": load("res://title/customization/assets/images/themes/castle/castle_gray.png"),
		"requirement": "Complete Normal Mode to Unlock This Background",
		"unlocked": SaveSystem.is_unlocked("Hard")
	},
	{
		"name": "space",
		"texture": load("res://title/customization/assets/images/themes/space/space.png"),
		"locked_texture": load("res://title/customization/assets/images/themes/space/space_gray.png"),
		"requirement": "Complete Hard Mode to Unlock This Background",
		"unlocked": SaveSystem.is_unlocked("Extreme")
	}
]

var can_move = true

onready var tween = $Tween

signal exit_customization()
signal theme_selected()

func _ready():
	theme_index = lookup_theme_index(CustomizationSystem.data["theme"])
	selected_theme = lookup_theme_index(CustomizationSystem.data["theme"])
	display_1.get_node("TextureRect").texture = themes[theme_index]["texture"]
	update_select_label()

func lookup_theme_index(name):
	for x in range(0, len(themes)):
		if themes[x]["name"] == name:
			return x
	return -1
	
func update_select_label():
	select_label.text = "Select" if selected_theme != theme_index else "Selected"

func move(direction: int):
	reset_display_holder()
	reset_display(display_1, 0)
	
	theme_index += direction
	if theme_index < 0:
		theme_index = themes.size() - 1
	elif theme_index > themes.size() - 1:
		theme_index = 0
	reset_display(display_2, 1920 * direction)
	swap_displays(-1920 * direction)
	
	update_select_label()
	
	
func reset_display(display, pos_x):
	display.position.x = pos_x
	
	if is_unlocked():
		display.get_node("TextureRect").texture = themes[theme_index]["texture"]
		display.get_node("Label").text = ""
	else:
		display.get_node("TextureRect").texture = themes[theme_index]["locked_texture"]
		display.get_node("Label").text = themes[theme_index]["requirement"]
		

func reset_display_holder():
	can_move = false
	display_holder.position.x = 0
	
	
func is_unlocked():
	return(themes[theme_index]["unlocked"])


func swap_displays(destination_x: int):
	tween.interpolate_property(display_holder, "position",
		display_holder.position, Vector2(destination_x, 0), 1,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()


func _on_ButtonLeft_pressed():
	if can_move:
		move(-1)


func _on_ButtonRight_pressed():
	if can_move:
		move(1)


func _on_ButtonSelect_pressed():
	if is_unlocked():
		CustomizationSystem.data["theme"] = themes[theme_index]["name"]
		CustomizationSystem.save_data()
		emit_signal("theme_selected")
		selected_theme = theme_index
		update_select_label()


func _on_ButtonBack_pressed():
	emit_signal("exit_customization")


func _on_Tween_tween_completed(_object, _key):
	can_move = true
