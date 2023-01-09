extends GridContainer
@tool

func _ready():
	# Populate inventroy with appropriate amount of grid slots
	for y  in Inventory.GRID_H:
		for x in Inventory.GRID_W:
			add_child(InventorySlot.new(x,y,Inventory.CELL_SIZE))
