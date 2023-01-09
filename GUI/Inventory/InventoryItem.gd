extends Control
var  inventory_item = preload("res://GUI/Inventory/InventoryItem.tscn")
var dimentions := Vector2(1,2)
var is_rotated := false;
var grid_position := Vector2(0,0)
var dragging = false:
	set(dragging):
		if dragging:
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			$TextureRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			mouse_filter = Control.MOUSE_FILTER_STOP
			$TextureRect.mouse_filter = Control.MOUSE_FILTER_STOP


func _get_drag_data(at_position):
	Inventory.dragging = true
	dragging = true
	set_drag_preview(self.duplicate(DUPLICATE_USE_INSTANTIATION))
	return self


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false
