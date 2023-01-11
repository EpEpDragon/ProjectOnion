extends GridContainer
@tool
@onready var bag = $"../../../../../../"
func _ready():
	# Populate inventroy with appropriate amount of grid slots
	for y  in bag.GRID_H:
		for x in bag.GRID_W:
			add_child(InventorySlot.new(x,y,Bag.CELL_SIZE))
