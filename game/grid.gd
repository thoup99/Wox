extends Node2D


const CENTERX = 960
const CENTERY = 570

var tile = load("res://shared/tile/Tile.tscn")
var tiles = []

var top_left = Vector2.ZERO
var bot_right = Vector2.ZERO

var size

func create_grid(inSize):
	size = inSize
	var half_tile = TileVariables.size / 2
	var start = -(size/2) * TileVariables.size + TileVariables.size / 2
	if inSize % 2 == 1:
		start -= TileVariables.size / 2
	
	for r in range(0, size):
		tiles.append([])
		for c in range(0, size):
			tiles[r].append(tile.instance())
			var tilePos = Vector2(CENTERX + start + c * TileVariables.size, CENTERY + start + r * TileVariables.size)
			tiles[r][c].position = tilePos
			add_child(tiles[r][c])
	

	top_left = Vector2(tiles[0][0].position.x - half_tile, tiles[0][0].position.y - half_tile)
	bot_right = Vector2(tiles[size - 1][size - 1].position.x + half_tile, tiles[size - 1][size - 1].position.y + half_tile)
	
func is_point_in(pos: Vector2):
	if pos.x > top_left.x and pos.x < bot_right.x + TileVariables.size:
		if pos.y > top_left.y and pos.y < bot_right.y + TileVariables.size:
			return true
	return false
	
func get_col(index: int):
	var col = []
	for row_arr in tiles:
		col.append(row_arr[index].letter)
