extends Node

onready var menu_options = $MenuOptions
var next_menu = 0

onready var image = $Control/CenterContainer/TextureRect
onready var label = $Control/Label

onready var animator = $AnimationPlayer

onready var data = {
	"dragging":
		{
			"texture": load("res://title/menus/assets/dragging.png"),
			"text": "Clicking on one of the light gray blocks on either side of the play area will allow you to drag it around the screen. Once dragging you can choose to put the block in the placement grid or release it to send it back to the selection area."
		},
	"rotating":
		{
			"texture": load("res://title/menus/assets/rotating.png"),
			"text": "While dragging a block you have the ability to rotate it. By pressing \"A\" or the left arrow key the block will be rotated 90° counterclockwise. Likewise, pressing \"D\" or the right arrow key will rotate the block 90° clockwise."
		},
	"clearing":
		{
			"texture": load("res://title/menus/assets/clearing.png"),
			"text": "Words can be cleared from left to right or top to bottom. The minimum word length is 4 letters. Anything less than that will not be cleared."
		},
	"difficulty":
		{
			"texture": load("res://title/menus/assets/difficulty.png"),
			"text": "Changing the difficulty will affect the play area in 2 ways. The first thing that will be affected is the placement grid. Its size will change depending on difficulty. The second thing that will be affected is the amount of blocks available for use each turn."
		},
	"game over":
		{
			"texture": load("res://title/menus/assets/game_over.png"),
			"text": "A game over will occur when no blocks in the selection area can fit into the placement grid. If your score is high enough when a game over occurs you will be asked to provide a name to put on the leaderboard."
		}
	}

signal leaving

func _ready():
	pass

func _on_menuitem_hover(i: int):
	match(i):
		0:
			swap_data("dragging")
		1:
			swap_data("rotating")
		2:
			swap_data("clearing")
		3:
			swap_data("difficulty")
		4:
			swap_data("game over")
		5:
			pass
	
func _on_menuitem_confirm(i: int):
	match(i):
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			pass
		5:
			emit_signal("leaving")
			all_leave()
			next_menu = 0
			
func swap_data(name: String):
	image.texture = data[name]["texture"]
	label.text = data[name]["text"]
		
func all_enter():
	animator.play("fade_in")
	menu_options.all_enter()
	
func all_leave():
	animator.play("fade_out")
	menu_options.all_leave()
