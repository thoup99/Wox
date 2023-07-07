extends Node

var block_movers = []
var num_movers = 1

func init(movers):
	num_movers = movers
	block_movers = get_children()
	
	for i in range(block_movers.size()-1 , num_movers-1, -1):
		block_movers[i].queue_free()
		block_movers.pop_back()

func generate_new_all():
	for i in range(0, num_movers):
		block_movers[i].generate_new_shape()

func set_lock_all(state):
	for i in range(0, num_movers):
		block_movers[i].set_lock(state)
		
func rotate_all(num):
	for i in range(0, num_movers):
		block_movers[i].block_end.rotate90(num)
