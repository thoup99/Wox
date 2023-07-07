extends Node

var game_path = "res://game/Game.tscn"
var main_menu_path = "res://title/Title.tscn"

onready var animation_player = $AnimationPlayer


var loaded_scene
var scene_to_load
var starting = true

var game_grid_size = 20
var game_num_blocks = 3
var game_time = 800
var game_difficulty = "Easy"

func _ready():
	randomize()
	load_main_menu()
	
	
func swap_scenes(path_to_scene, unload = true):
	if unload:
		loaded_scene.free() #if anything breaks change this to queue_free
		SfxManager.play("res://main/ding.wav")
	
	var temp = load(path_to_scene)
	loaded_scene = temp.instance()
	add_child(loaded_scene)
	
func load_game(grid_size = game_grid_size, num_blocks = game_num_blocks, time = game_time, diff = game_difficulty):
	game_grid_size = grid_size
	game_num_blocks = num_blocks
	game_time = time
	game_difficulty = diff
	scene_to_load = "game"
	animation_player.play("in")
	
func init_game():
	swap_scenes(game_path)
	
	loaded_scene.connect("exit_to_menu", self, "load_main_menu")
	loaded_scene.connect("restart", self, "load_game")
	
	loaded_scene.play(game_grid_size, game_num_blocks, game_time, game_difficulty)
	animation_player.play("out")
	
func load_main_menu():
	scene_to_load = "main_menu"
	
	if not starting:
		animation_player.play("in")
	else:
		init_main_menu()

func init_main_menu():
	swap_scenes(main_menu_path, !starting)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	loaded_scene.get_node("MenuSelection").connect("play", self, "load_game")
	
	if not starting:
		animation_player.play("out")
	else:
		starting = false
	
	
func load_scene(scene_name):
	scene_to_load = scene_name
	animation_player.play("in")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "in":
		if scene_to_load == "main_menu":
			init_main_menu()
		elif scene_to_load == "game":
			init_game()
	if anim_name == "out" and scene_to_load == "game":
		loaded_scene._on_loading_screen_done()
			
			
func _input(event):
	if event.is_action_pressed("screenshot"):
		screenshot()
		
			
func screenshot():
	if !Directory.new().dir_exists("user://screenshots"):
		if !Directory.new().make_dir("user://screenshots"):
			print("Error creating screenshot directory")
			return
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	var time = Time.get_datetime_string_from_system().replace(":", "-")
	image.save_png("user://screenshots//" + time + ".png")
