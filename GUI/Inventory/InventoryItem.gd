extends Control
class_name InventoryItem
var  inventory_item = preload("res://GUI/Inventory/InventoryItem.tscn")

var drag_preview

var is_dragging = false:
	set(dragging): # Disable/Enable mouse input on original item based on dragging
		is_dragging = dragging
		if is_dragging:
			visible = false
		else:
			visible = true

var dimentions := Vector2i(1,1):
	set(dim_new):
#		clear_occupation_flags()
		dimentions = dim_new
#		set_occupation_flags()
		Inventory.clear_drop_preview()
		size = dimentions*Inventory.CELL_SIZE - Vector2i(6,6)

var grid_position := Vector2i(0,0):
	set(pos_new):
#		clear_occupation_flags()
		grid_position = pos_new
#		set_occupation_flags()
		Inventory.clear_drop_preview()
		position = grid_position * Inventory.CELL_SIZE + Vector2i(4,10)

var is_rotated := false:
	set(rotated):
		is_rotated = rotated
		if is_rotated:
			drag_preview.size = Vector2i(dimentions.y, dimentions.x)*Inventory.CELL_SIZE - Vector2i(6,6)
		else:
			drag_preview.size = dimentions*Inventory.CELL_SIZE - Vector2i(6,6)
		
		# HACK To force an update on _can_drop_data in relevant grid slot
		# I don't think theres a force update method.
		get_viewport().warp_mouse(get_viewport().get_mouse_position())


func _get_drag_data(_at_position):
	clear_occupation_flags()
	drag_preview = self.duplicate(0) # Duplicate as totally empty and unconnected
	set_drag_preview(drag_preview)
	is_dragging = true
	return self


# Detect drag cancel
func _input(event):
	if is_dragging:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				is_dragging = false
				Inventory.clear_drop_preview()
		elif event.is_action_pressed("interact"):
			is_rotated = not is_rotated
			print(is_rotated)


func clear_occupation_flags():
	for x in dimentions.x:
		for y in dimentions.y:
			Inventory.grid.get_child(grid_position.x + grid_position.y*Inventory.GRID_W + x + y*Inventory.GRID_W).is_occupied = false


func set_occupation_flags():
	for x in dimentions.x:
		for y in dimentions.y:
			Inventory.grid.get_child(grid_position.x + grid_position.y*Inventory.GRID_W + x + y*Inventory.GRID_W).is_occupied = true
