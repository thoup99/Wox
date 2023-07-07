extends Node

onready var background = $"../Background"

onready var rotate_left = $"../RotateLeft"
onready var score = $"%Score"
onready var time = $"%Time"
onready var cleared = $"%Cleared"
onready var rotate_right = $"../RotateRight"

onready var main_track = $"%MainTrack"

var theme_path = "res://game/assets/images/themes/default/"
var theme_name = "default"
var font_color = Color(1, 1, 1)


func load_theme(name):
	theme_path = "res://game/assets/images/themes/" + name.to_lower() + "/"
	theme_name = name.to_lower()
	
	match theme_name:
		"jungle":
			font_color = Color(0.03595, 0.296875, 0.071262)
	
	background.get_node("BGrect").texture = load(theme_path + "background.png")
	update_rotate_sign(rotate_left)
	update_label_sign(score)
	update_label_sign(time)
	update_label_sign(cleared)
	update_rotate_sign(rotate_right)
	
	update_main_track(theme_name)
	update_main_track(theme_name)
	

func update_rotate_sign(ui: Node2D):
	var chains = ui.get_node("Chains")
	var single = ui.get_node("Single")
	var rotate = ui.get_node("Rotate")
	var label = ui.get_node("Label")
	
	update_chains(chains)
	
	single.texture = load(theme_path + "single.png")
	label.set("custom_colors/font_color", font_color)
	rotate.modulate = font_color
	

func update_label_sign(ui: Node2D):
	var chains = ui.get_node("Chains")
	var sign_small = ui.get_node("SignSmall")
	var sign_medium = ui.get_node("SignMedium")
	
	var label = ui.get_node("Label")
	var value = ui.get_node("Value")
	
	update_chains(chains)
	
	sign_small.texture = load(theme_path + "sign_small.png")
	sign_medium.texture = load(theme_path + "sign_medium.png")
		
	label.set("custom_colors/font_color", font_color)
	value.set("custom_colors/font_color", font_color)
	
func update_chains(chains):
	var texture = load(theme_path + "chain.png")
	for child in chains.get_children():
		child.texture = texture

func update_main_track(name):
	main_track.stream = load("res://game/assets/music/themes/" + name.to_lower() + ".ogg")
