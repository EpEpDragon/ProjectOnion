extends PanelContainer
class_name InventorySlot

var is_occupied = false
var _index_x
var _index_y
var _dim_drag
@onready var grid = $".."

func _init(i_x, i_y, cell_size):
	_index_x = i_x
	_index_y = i_y
	custom_minimum_size = Vector2(cell_size, cell_size)


func _can_drop_data(_at_position, data):
	# TODO Make can drop method cleaner if possible
	Inventory.clear_drop_preview()
	
	var color
	var can_drop
	

	if data.is_rotated:
		_dim_drag = Vector2(data.dimentions.y, data.dimentions.x)
	else:
		_dim_drag = Vector2(data.dimentions.x, data.dimentions.y)
	
	# Check if can drop
	if _is_block_occupied():
		color = Color.RED
		can_drop = false
	else:
		color = Color.GREEN
		can_drop = true
	
	# Set drop preview color
	for y in _dim_drag.y:
		for x in _dim_drag.x:
			if x + _index_x >= Inventory.GRID_W or y + _index_y >= Inventory.GRID_H:
				continue
			grid.get_child(get_index() + x + y*Inventory.GRID_W).modulate = color
	
	# Handle drop cancel case
	if not data.is_dragging and not can_drop:
		data.set_occupation_flags()
		Inventory.clear_drop_preview()
		data.is_rotated = false
		
	return can_drop


func _drop_data(_at_position, data):
	data.grid_position = Vector2(_index_x, _index_y)
	data.dimentions = _dim_drag
	data.set_occupation_flags()
	
	# DEBUG
	Inventory.clear_drop_preview()
	
	data.is_rotated = false


func _is_block_occupied():
	# Check inventroy overflow
	if _index_x + _dim_drag.x > Inventory.GRID_W or _index_y + _dim_drag.y > Inventory.GRID_H:
		return true
	# Check overlap with other blocks
	for y in _dim_drag.y:
		for x in _dim_drag.x:
			if grid.get_child(get_index() + x + y*Inventory.GRID_W).is_occupied:
				return true
	return false
