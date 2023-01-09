extends PanelContainer
class_name InventorySlot

var is_occupied = false
var index_x
var index_y

@onready var grid = $".."

func _init(pos_x, pos_y, cell_size):
	index_x = pos_x
	index_y = pos_y
	custom_minimum_size = Vector2(cell_size, cell_size)

func _can_drop_data(at_position, data):
	for i in Inventory.GRID_H*Inventory.GRID_W:
		grid.get_child(i).modulate = Color.WHITE
	print("Can drop")
	print(get_index())
	var color
	if is_block_occupied(get_index(), index_x, index_y, data.dimentions):
		color = Color.RED
	else:
		color = Color.GREEN
	for y in data.dimentions.y:
		for x in data.dimentions.x:
			if x + index_x >= Inventory.GRID_W or y + index_y >= Inventory.GRID_H:
				continue
			grid.get_child(get_index() + x + y*Inventory.GRID_W).modulate = color
	return true

func _drop_data(at_position, data):
	for i in Inventory.GRID_H*Inventory.GRID_W:
		grid.get_child(i).modulate = Color.WHITE
	print("Drop")

func is_block_occupied(i:int, i_x:int, i_y:int, dim : Vector2):
	print("x: %s" % index_x)
	print("y: %s" % index_y)
	for y in dim.y:
		for x in dim.x:
			if x + index_x >= Inventory.GRID_W or y + index_y >= Inventory.GRID_H:
				return true
			if grid.get_child(i + x + y*Inventory.GRID_W).is_occupied:
				return true
	return false
