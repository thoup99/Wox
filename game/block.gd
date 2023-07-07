extends Node2D

onready var screen_size = get_viewport_rect().size

var shape = []
var start_position
var tile = preload("res://shared/tile/Tile.tscn")
var tiles = []

var letters = [
		["a", "c", "e", "i", "l", "n", "o", "r", "s", "t"],
		["b", "d", "f", "g", "h", "m", "p", "u", "y"],
		["j", "k", "q", "v", "w", "x", "z"]
	]

var locked = false

var top_left
var bot_right
var dragging = false
var lerping = false
var f = 0.01

signal selected(this_node)
signal unselected()

	
func create(pos :Vector2):
	start_position = pos
	load_shape()
	create_tiles()
	position = start_position
	update_corners()

func load_shape():
	#Randomly selects a shape and selects letters for each tile
	var shapes = [
		[
			[" ", " ", "x", " "],
			[" ", " ", "x", " "],
			[" ", " ", "x", " "],
			[" ", " ", "x", " "]
		],
		[
			[" ", " ", " ", " "],
			[" ", "x", "x", " "],
			["x", "x", " ", " "],
			[" ", " ", " ", " "]
		],
		[
			[" ", " ", " ", " "],
			[" ", "x", "x", " "],
			[" ", " ", "x", "x"],
			[" ", " ", " ", " "]
		],
		[
			[" ", "x", " ", " "],
			[" ", "x", " ", " "],
			[" ", "x", "x", " "],
			[" ", " ", " ", " "]
		],
		[
			[" ", " ", "x", " "],
			[" ", " ", "x", " "],
			[" ", "x", "x", " "],
			[" ", " ", " ", " "]
		],
		[
			[" ", "x", " ", " "],
			[" ", "x", "x", " "],
			[" ", "x", " ", " "],
			[" ", " ", " ", " "]
		],
		[
			[" ", " ", " ", " "],
			[" ", "x", "x", " "],
			[" ", "x", "x", " "],
			[" ", " ", " ", " "]
		],
		[
			[" ", " ", " ", " "],
			[" ", "x", "x", "x"],
			[" ", "x", " ", " "],
			[" ", "x", " ", " "]
		],
		[
			[" ", " ", " ", " "],
			[" ", "x", "x", " "],
			[" ", "x", " ", " "],
			[" ", " ", " ", " "]
		]
	]
	
	shape = shapes[randi() % shapes.size()] #Picks a random shape from table
	
	for r in range(0, 4):
		for c in range(0, 4):
			if shape[r][c] == "x":
				shape[r][c] = get_random_letter()


func get_random_letter():
	#Gets a random letter by weight. More common letters have a higher chance of appearing.
	var value = rand_range(0, 100)
	var i = -1
	if value >= 50:
		i = 0
	elif value >= 5:
		i = 1
	else:
		i = 2
		
	return letters[i][rand_range(0, letters[i].size())]

func create_tiles():
	var start = -2 * TileVariables.size + TileVariables.size / 2
	
	
	for r in range(0, 4):
		for c in range(0, 4):
			if shape[r][c] != " ":
				tiles.append(tile.instance())
				var tilePos = Vector2(start + c * TileVariables.size, start + r * TileVariables.size)
				tiles[tiles.size() - 1].position = tilePos
				tiles[tiles.size() - 1].change_letter(shape[r][c])
				if locked:
					tiles[tiles.size() - 1].change_color(TileVariables.color_light_gray)
				add_child(tiles[tiles.size() - 1])


func remove_tiles():
	for old_tile in tiles:
		old_tile.queue_free()
		
	tiles = []
	
func rotate90(times):
	#Times = 1: 90°
	#times = 3: 270° / -90°
	
	for _x in range (times):
		var N = shape.size()
		for i in range(N / 2):
			for j in range(i, N - i - 1):
				var temp = shape[i][j]
				shape[i][j] = shape[N - 1 - j][i]
				shape[N - 1 - j][i] = shape[N - 1 - i][N - 1 - j]
				shape[N - 1 - i][N - 1 - j] = shape[j][N - 1 - i]
				shape[j][N - 1 - i] = temp


	for child_tile in tiles:
		child_tile.queue_free()
	tiles = []
		
	create_tiles()


func _input(event):
	if not locked:
		#Rotating
		if dragging and false:
			if event.is_action_pressed("rotate_left"):
				rotate90(3)
			if event.is_action_pressed("rotate_right"):
				rotate90(1)
				
		#Dragging
		if event.is_action_pressed("left_click"):
			
			if check_bounds_mouse():
				emit_signal("selected", self)
				z_index = 1
				dragging = true
				lerping = false
			
		elif event.is_action_released("left_click"):
			if dragging:
				emit_signal("unselected")
				stop_dragging()
			
func _notification(what):
	#Drops the block when the window loses focus
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if dragging:
				emit_signal("unselected")
				stop_dragging()
	
func stop_dragging():
	z_index = 0
	lerping = true
	dragging = false


func _process(delta):
	if dragging:
		var pos: Vector2
		if !CursorData.is_active:
			pos = get_viewport().get_mouse_position()
		else:
			pos = CursorData.position
			
		move_to_point(pos)
		
	if lerping:
		position = lerp(position, start_position, 1 - pow(f, delta))
		update_corners()
		
		if position.is_equal_approx(start_position):
			lerping = false
			position = start_position


func update_corners():
	#Updates the Vector2 position of the edges of the block
	top_left = Vector2(position.x - TileVariables.size * 2, position.y - TileVariables.size * 2)
	bot_right = Vector2(position.x + TileVariables.size * 2, position.y + TileVariables.size * 2)
	
	
func move_to_point(point: Vector2):
	position = point
	

func check_bounds_mouse():
	var pos: Vector2
	if !CursorData.is_active:
		pos = get_viewport().get_mouse_position()
	else:
		pos = CursorData.position
		
	var distance = sqrt(pow(pos.x - start_position.x ,2) + pow(pos.y - start_position.y ,2))
	
	return(distance <= 105)

func fade_in():
	$AnimationPlayer.play("in")
