extends Node

onready var grid = $"%Grid"
onready var block_mover_manager = $"%BlockMoverManager"
onready var timer = $Timer
onready var hint_timer = $HintTimer
onready var ui_rotate_left = $RotateLeft
onready var ui_score = $"%Score"
onready var ui_time = $"%Time"
onready var ui_time_label = $"%Time".get_node("Value")
onready var ui_cleared = $"%Cleared"
onready var ui_rotate_right = $RotateRight

onready var main_track = $"%MainTrack"
onready var paused_track = $"%PausedTrack"

onready var sign_rotate_left = $RotateLeft
onready var game_end = $"%GameEnd"
onready var score_submitter = $"%ScoreSubmitter"
onready var pause_screen = $"%PauseMenu"
onready var sign_rotate_right = $RotateRight

onready var cursor = $Cursor

var word_list: PoolStringArray

var is_dragging
var is_mouse_moving
var is_rotating
var block_dragging
var grid_cords: Array
var grid_cords_last: Array
var does_fit = false

var mouse_pos

var score: int
var words_cleared: int
var cleared_words: PoolStringArray
var difficulty = "Easy"
var lb : LeaderboardData

var hint_tiles_cords = []

var is_game_over = false
var is_paused = false

onready var text_effect_manger = $"%TextEffectManager"
var bottums_up = load("res://game/text_effects/BottomsUp.tscn")
var blow_up = load("res://game/text_effects/BlowUp.tscn")
var fly_up = load("res://game/text_effects/FlyUp.tscn")

var normal_goal = 10
var hard_goal = 15
var extreme_goal = 10
var stage_cleared = false

var time_to_add = 0

var is_muted = false

onready var tween = $Tween

onready var fps_counter = $FPSCounter

onready var rotate_left_label = $RotateLeft/Label
onready var rotate_right_label = $RotateRight/Label

signal exit_to_menu
signal restart

func play(grid_size : int, available_blocks : int, start_time : int, diff: String):
	#Called at the start of each round. Sets all of the rules for each difficulty.
	grid.create_grid(grid_size)
	block_mover_manager.init(available_blocks)
	difficulty = diff
	lb = ScoreSystem.get_local(ScoreSystem.get_enum_from_string(diff))
	
	grid.z_index = -1
			
	for block_mover in block_mover_manager.block_movers:
		block_mover.block_end.connect("selected", self, "_on_block_selected")
		block_mover.block_end.connect("unselected", self, "_on_block_unselected")
	
	
	var f = File.new()
	f.open("res://game/word_list.tres", f.READ)
	
	while not f.eof_reached(): 
		word_list.append(f.get_line())
		
	f.close()
	
	if difficulty == "Easy" and SaveSystem.is_unlocked("Normal"):
		stage_cleared = true
	elif difficulty == "Normal" and SaveSystem.is_unlocked("Hard"):
		stage_cleared = true
	elif difficulty == "Hard" and SaveSystem.is_unlocked("Extreme"):
		stage_cleared = true
	else:
		var temp = fly_up.instance()
		if difficulty == "Easy":
			text_effect_manger.add_to_queue(temp, "Clear "+str(normal_goal)+" words to unlock Normal mode!")
		if difficulty == "Normal":
			text_effect_manger.add_to_queue(temp, "Clear "+str(hard_goal)+" words to unlock Hard mode!")
		if difficulty == "Hard":
			text_effect_manger.add_to_queue(temp, "Clear "+str(extreme_goal)+" words to unlock Extreme mode!")
	
	
	$BlurRect.visible = false
	
	if SettingsSystem.game_data["display_fps"]:
		fps_counter.visible = true
	
	$ThemeManager.load_theme(CustomizationSystem.data["theme"])
	timer.start(start_time)
	
	
func _on_block_selected(block):
	#Sets block_dragging to the block that is being dragged. Also sets is_dragging to true
	is_dragging = true
	block_dragging = block
	if !CursorData.is_active:
		mouse_pos = get_viewport().get_mouse_position()
	else:
		mouse_pos = CursorData.position
	SfxManager.play("res://game/assets/sound/click.ogg")
	
func _on_block_unselected():
	#Sets is_dragging to false, undos highlighting, and palces a block if applicable.
	is_dragging = false
	undo_highlight()
	if does_fit and grid.is_point_in(mouse_pos):
		drop_shape(block_dragging.shape)
		check_for_words()
		update_blocks()
		check_for_game_over()
		reset_hint_timer()
		reset_hint_tiles()
	
	SfxManager.play("res://game/assets/sound/drop.ogg")

func grid_change_color(position: Vector2, color):
	grid.tiles[position.x][position.y].change_color(color)
	
func get_grid_mouse_cords():
	#Gets to position of the mouse relative to the top left corner of the grid
	var relative_pos = Vector2(mouse_pos.x - grid.top_left.x + TileVariables.size / 2, mouse_pos.y - grid.top_left.y + TileVariables.size / 2)
	var cords = Vector2(relative_pos.x / TileVariables.size, relative_pos.y / TileVariables.size)
	cords.x = int(cords.x)
	cords.y = int(cords.y)
	return cords
	
func get_grid_cords(start: Vector2, shape: Array):
	#Gets the index of each tile in the form of a Vector2 to properly access the 2d array
	does_fit = true
	for r in range(-2, shape.size() -2):
		for c in range(-2, shape[r].size()-2):
			if shape[r+2][c+2] == ' ':
				continue
			
			elif start.y + r < grid.size and start.y + r >= 0 and start.x + c < grid.size and start.x + c >= 0:
				if !grid.tiles[start.y + r][start.x + c].letter == ' ':
					does_fit = false
				grid_cords.append(Vector2(start.y + r, start.x + c))
				
			else:
				does_fit = false
				
	
func drop_shape(shape: Array):
	#If the block being dragged fits on the grid it will be placed
	if !does_fit:
		return
		
	var index = 0
	for r in range(0, shape.size()):
		for c in range(0, shape.size()):
			if not shape[r][c] == ' ':
				grid.tiles[grid_cords[index].x][grid_cords[index].y].change_letter(shape[r][c])
				grid.tiles[grid_cords[index].x][grid_cords[index].y].set_default_color(TileVariables.color_yellow)
				index += 1


func binarySearch(search: String):
	var low = 0
	var high = word_list.size() -1
	
	while high >= low :
		var mid = (low + high)/2
		if (search == word_list[mid]):
			return true
   
		elif (search > word_list[mid]):
			low = mid + 1

		else:
			high = mid - 1
			
	return false


func check_for_words():
	#Searches for words present in the grid only in the rows/columns that had tiles placed.
	var rows = []
	var cols = []
	for cord in grid_cords:
		if not rows.has(cord.x):
			rows.append(cord.x)
				
		if not cols.has(cord.y):
			cols.append(cord.y)
			
	var row_data = []
	var col_data = []
	
	for row in rows:
		var words = search_array_for_words(row, grid.tiles[row])
		if words.size() > 0:
			row_data.append(words)
	for col in cols:
		var col_arr = []
		for row in grid.tiles:
			col_arr.append(row[col])
			
		var words = search_array_for_words(col, col_arr)
		if words.size() > 0:
			col_data.append(words)
		
	clear_rows(row_data)
	clear_cols(col_data)
	
	update_UI()
	
	
func search_array_for_words(arr_num: int, arr: Array):
	#arr_data should be formated as follows
	#[[arr_num, start(inclusive), stop(exclusive]]
	#
	var arr_data = []
	var start = -1
	var end = -1
	
	for i in range(0, arr.size()):
		var letter = arr[i].letter
				
		if (letter == ' ' or i == arr.size() - 1) and not start == -1:
			end = i

			#Test all combos and add to arr_data
			var start_offset = 0
			for _x in range(0, end - start):
				var end_offset = 0
				for _y in range(0, end - end_offset - start + start_offset):
					var word = ""
					for j in range(start + start_offset, end - end_offset + 1):
						word += arr[j].letter
						
					if word.length() > 3:
						if binarySearch(word):
							arr_data.append([arr_num, start + start_offset, end - end_offset + 1]) 
							words_cleared += 1
							score += int(100 + 10 * word.length())
							cleared_words.append(word)

							var temp = blow_up.instance()
							text_effect_manger.add_to_queue(temp, word)
							
							check_for_clear()
					
					
					end_offset += 1
				start_offset += 1


			#Reset
			start = -1
			end = -1
				
		else:
			if start == -1 and not letter == ' ':
				start = i
	
	return arr_data

#Data should be formated as follows
#[[row, start(inclusive), end(exclusive)], [row, tart(inclusive), end(exclusive)]]
func clear_rows(data: Array):
	for row in data:
		for row_data in row:
			for i in range(row_data[1], row_data[2]):
				grid.tiles[row_data[0]][i].change_letter(' ')
				grid.tiles[row_data[0]][i].set_default_color(TileVariables.color_normal)
				time_to_add += 3
				
func clear_cols(data: Array):
	for col in data:
		for col_data in col:
			for i in range(col_data[1], col_data[2]):
				grid.tiles[i][col_data[0]].change_letter(' ')
				grid.tiles[i][col_data[0]].set_default_color(TileVariables.color_normal)
				time_to_add += 3
				
func undo_highlight():
	#Removes preview highlighting
	for cord in grid_cords_last:
		grid.tiles[cord.x][cord.y].change_color(grid.tiles[cord.x][cord.y].default_color)
	
	
func unique_shapes(shapes: Array):
	#Removes any duplicate shapes from the provided array
	var unique = []
	for shape in shapes:
		var fixed = fix_shape(shape)
		if not fixed in unique:
			unique.append(fixed)
	return unique
		
func fix_shape(shape: Array):
	#Removes edges from a shapes array. Example: Changes a 4x4 2d array into a 2x3 2d array to make searching faster
	var fixed = []
	var good_col = []

	for row in shape:
		var add_row = false
		var y  = 0
		for item in row:
			if item != ' ':
				add_row = true
				if !y in good_col:
					good_col.append(y)
			y += 1

		if add_row:
			fixed.append(row)
			
	var r = 0
	for row in fixed:
		for c in range(len(row) - 1, 0 - 1, -1):
			if !c in good_col:
				fixed[r].remove(c)
		r += 1
		
	var x = 0
	for row in fixed:
		var y = 0
		for item in row:
			if item != ' ':
				fixed[x][y] = 'x'
			y+=1
		x += 1

	return fixed
		
func does_shape_fit(shape: Array, update_hint = false):
	#Checks if the tiles the shape is hovering over is occupied by a letter
	for y in range(grid.tiles.size() - shape.size() + 1):
		for x in range(grid.tiles.size() - shape[0].size() + 1):
			var fit = true
			var spaces = []
			for r in range(len(shape)):
				for c in range(len(shape[r])):
					if shape[r][c] == ' ':
						continue
						
					elif y + r < grid.tiles.size() and x + c < grid.tiles.size():
						if not grid.tiles[y + r][x + c].letter == ' ':
							fit = false
						spaces.append(Vector2(y + r, x + c))
			if fit:
				if update_hint:
					hint_tiles_cords = spaces
				return true
				
	return false
	
func get_all_shape_rotations(index: int):
	var every_rotation = []
	for _x in range(4):
		every_rotation.append(block_mover_manager.block_movers[index].block_end.shape.duplicate(true))
		block_mover_manager.block_movers[index].block_end.rotate90(1)
		
	return every_rotation

func check_for_game_over():
	var every_shape = []
	
	for i in range(block_mover_manager.block_movers.size()):
		every_shape += get_all_shape_rotations(i)
	
	every_shape = unique_shapes(every_shape)
	
	for shape in every_shape:
		if does_shape_fit(shape):
			return
	game_over()

func update_blocks():
	block_mover_manager.generate_new_all()

	
func update_UI():
	ui_score.get_node("Value").text = str(score)
	ui_cleared.get_node("Value").text = str(words_cleared)
	
	var current_time = timer.time_left
	timer.start(current_time + time_to_add)
	time_to_add = 0
	
func placed():
	#Returns the place the score qualifies for on the leaderboard.
	var lb_data_clean = ScoreSystem.get_local(ScoreSystem.get_enum_from_string(difficulty))
	for x in range(0, 10):
		if lb_data_clean.get_score(x) < score:
			return x + 1
	return -1
	
func check_for_clear():
	#Checks to see if the currently selected difficulty was cleared.
	if stage_cleared:
		return
		
	if difficulty == "Easy" and words_cleared >= normal_goal:
		if !SaveSystem.is_unlocked("Normal"):
			SaveSystem.unlock_difficulty("Normal")
			notify_unlock("Normal")
		
	elif difficulty == "Normal" and words_cleared >= hard_goal:
		if !SaveSystem.is_unlocked("Hard"):
			SaveSystem.unlock_difficulty("Hard")
			notify_unlock("Hard")
		
	elif difficulty == "Hard" and words_cleared >= extreme_goal:
		if !SaveSystem.is_unlocked("Extreme"):
			SaveSystem.unlock_difficulty("Extreme")
			notify_unlock("Extreme")

		
func notify_unlock(diff: String):
	var temp = bottums_up.instance()
	text_effect_manger.add_to_queue(temp, diff + " Mode Unlocked!")
	
	
func game_over():
	if !is_game_over:
		force_stop_block_dragging()
		is_game_over = true
		block_mover_manager.set_lock_all(true)

		$BlurRect/AnimationPlayer.play("BlurIn")
		if placed() == -1:
			show_game_end()
		else:
			score_submitter.open_score_submitter(score, placed(), lb)
			score_submitter.visible = true
			score_submitter.active = true
			
func force_stop_block_dragging():
	if is_dragging:
		block_dragging.stop_dragging()
		is_dragging = false
		undo_highlight()

func show_game_end():
	score_submitter.visible = false
	game_end.visible = true
	game_end.change_stats(score, words_cleared)
	if cleared_words.size() == 0:
		cleared_words.append("No Words Cleared")
	game_end.change_words_cleared(cleared_words)
	game_end.fill_leaderboard(difficulty)
		
func pause():
	#Pauses every timer and removes the blocks ability to move
	if !is_game_over:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		force_stop_block_dragging()
		timer.paused = true
		hint_timer.paused = true
		cursor.paused = true
		block_mover_manager.set_lock_all(true)

		main_track.stream_paused = true
		$BlurRect/AnimationPlayer.play("BlurIn")
		pause_screen.visible = true
		pause_screen.is_active = true
		paused_track.play()
	
func unpause():
	#Unpauses all functions of the game
	if CursorData.is_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	timer.paused = false
	hint_timer.paused = false
	cursor.paused = false
	block_mover_manager.set_lock_all(false)

	main_track.stream_paused = false
	$BlurRect/AnimationPlayer.play("BlurOut")
	pause_screen.visible = false
	pause_screen.is_active = false
	paused_track.stop()
	
func _input(event):
	if event.is_action_pressed("debug_mode"):
		fps_counter.visible = !fps_counter.visible
		
	if !is_game_over:
		
		if (event is InputEventMouseMotion) or (cursor.velocity[0] != 0 or cursor.velocity[1] != 0):
			is_mouse_moving = true
		else:
			is_mouse_moving = false
		
		if event.is_action_pressed("esc"):
			is_paused = !is_paused
			if is_paused:
				pause()
			else:
				unpause()
				
		elif event.is_action_pressed("give_up"):
			game_over()
			
		if !is_paused:
			var times = 0
			is_rotating = false
			if event.is_action_pressed("rotate_left"):
				times = 3
				is_rotating = true
			elif event.is_action_pressed("rotate_right"):
				times = 1
				is_rotating = true
				
			if !is_dragging:
				block_mover_manager.rotate_all(times)
			else:
				block_dragging.rotate90(times)
			
	
func _process(_delta):
	fps_counter.text = "FPS: " + str(Engine.get_frames_per_second())
	if not is_game_over:
		ui_time_label.text = "%d:%02d" % [floor(timer.time_left / 60), int(timer.time_left) % 60]
		if is_dragging and (is_mouse_moving or is_rotating):
			if !CursorData.is_active:
				mouse_pos = get_viewport().get_mouse_position()
			else:
				mouse_pos = CursorData.position
			
				
			grid_cords_last.append_array(grid_cords)
			grid_cords = []
			undo_highlight()
			
			
			if grid.is_point_in(mouse_pos):
				get_grid_cords(get_grid_mouse_cords(), block_dragging.shape)
				if does_fit:
					for cord in grid_cords:
						grid.tiles[cord.x][cord.y].change_color(TileVariables.color_green)
				else:
					for cord in grid_cords:
						grid.tiles[cord.x][cord.y].change_color(TileVariables.color_red)

func restart():
	emit_signal("restart")
	
func exit_to_menu():
	emit_signal("exit_to_menu")

func _on_PauseMenu_resume():
	is_paused = false
	unpause()
	
func _on_PauseMenu_give_up():
	is_paused = false
	unpause()
	game_over()
	
func _on_PauseMenu_restart():
	restart()

func _on_PauseMenu_mute(label, label_bold):
	is_muted = !is_muted
	
	label.text = "Unmute" if is_muted else "Mute"
	label_bold.text = "Unmute" if is_muted else "Mute"
	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), is_muted)


func _on_PauseMenu_exit_to_menu():
	exit_to_menu()

func _on_PauseMenu_quit():
	get_tree().quit()


func _on_GameEnd_retry():
	restart()

func _on_GameEnd_exit():
	exit_to_menu()

func insert_score(pos, values: Dictionary):
	if pos < 9:
		var stored_values = lb.data[pos].duplicate(true)
		lb.data[pos] = values
		insert_score(pos + 1, stored_values)
	else:
		lb.data[pos] = values

func _on_ScoreSubmitter_score_accepted(name):
	game_end.lb_gui.highlight_score(placed(), Color(0.878906, 0.812227, 0.102997))
	insert_score(placed() -1, {"name": name, "score": score})
	ScoreSystem.save_data(ScoreSystem.get_enum_from_string(difficulty), lb)
	game_end.lb_gui.update_board(difficulty, ScoreSystem.get_local(ScoreSystem.get_enum_from_string(difficulty)))
	show_game_end()


func _on_Timer_timeout():
	game_over()

func reset_hint_timer():
	if !is_game_over:
		hint_timer.start()
		
func reset_hint_tiles():
	#Removes highlighting applied to the grid for hints
	for cord in hint_tiles_cords:
		if grid.tiles[cord.x][cord.y].default_color == TileVariables.color_light_blue:
			grid.tiles[cord.x][cord.y].set_default_color(TileVariables.color_normal)
	hint_tiles_cords = []
		
func give_hint():
	#Searches for the first place on the board that a block can fit and highlights it. Starts in top left goes to bottom Right.
	for index in range(block_mover_manager.block_movers.size()):
		var all_rotations = get_all_shape_rotations(index)
		for shape in all_rotations:
			if does_shape_fit(fix_shape(shape), true):
				for cord in hint_tiles_cords:
					grid.tiles[cord.x][cord.y].set_default_color(TileVariables.color_light_blue)
				#highlight tiles in selction area
				return

func _on_HintTimer_timeout():
	if !is_game_over:
		give_hint()
		
func _on_loading_screen_done():
	main_track.play()
	tween_signs()

func tween_signs():
	tween_sign(ui_rotate_left, 4)
	tween_sign(ui_score)
	tween_sign(ui_time)
	tween_sign(ui_cleared)
	tween_sign(ui_rotate_right, 4)

func tween_sign(sign_ref, time = 2):
	tween.interpolate_property(sign_ref, "position",
		Vector2(sign_ref.position.x, sign_ref.position.y), Vector2(sign_ref.position.x, 0), time,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

func _on_Cursor_hiding():
	rotate_left_label.text = "A"
	rotate_right_label.text = "D"

func _on_Cursor_showing():
	rotate_left_label.text = "LB"
	rotate_right_label.text = "RB"
