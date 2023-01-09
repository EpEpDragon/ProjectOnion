extends GridContainer

func _ready():
	for y  in Inventory.GRID_H:
		for x in Inventory.GRID_W:
			add_child(InventorySlot.new(x,y,Inventory.CELL_SIZE))
