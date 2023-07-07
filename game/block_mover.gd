class_name BlockMover extends Node

onready var block = preload("res://game/Block.tscn")

var block_start
var block_end

onready var start_pos = $StartPos
onready var end_pos = $EndPos

func _ready():
	
	block_start = block.instance()
	block_start.locked = true
	block_start.create(start_pos.position)
	add_child(block_start)
	
	block_end = block.instance()
	block_end.create(end_pos.position)
	add_child(block_end)
	
	
func generate_new_shape():
	block_end.shape = block_start.shape
	block_end.remove_tiles()
	block_end.create_tiles()
	block_end.position = start_pos.position
	block_end.lerping = true
	
	
	block_start.load_shape()
	block_start.remove_tiles()
	block_start.create_tiles()
	block_start.fade_in()

	
func set_lock(state: bool):
	block_end.locked = state
