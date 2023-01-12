extends Control
class_name Bag

const CELL_SIZE = 80
const GRID_W = 10
const GRID_H = 7
const GRID_SIZE = GRID_W*GRID_H

var item = preload("res://GUI/Inventory/InventoryItem.tscn")
var items : Array[InventoryItem]

@onready var grid : GridContainer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer/InventoryGrid
@onready var item_layer : CanvasLayer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Spacer/CanvasLayer
@onready var grid_start = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GridStart

func _set(property, value):
	match property:
		"visible":
			visible = value
			item_layer.visible = value


func _ready():
	add_item("Canister", Vector2i(0,0))
	add_item("Canister", Vector2i(1,0))
	add_item("Canister", Vector2i(3,1))
	add_item("Box", Vector2i(4,0))


func add_item(id : String, grid_position := Vector2i.ZERO) -> void:
	var instance = item.instantiate()
	instance.id = id
	instance.bag = self
	instance.dimentions = ItemDb.ITEMS[id].dimentions
	instance.grid_position = grid_position
	instance.set_occupation_flags()
	items.append(instance)
	grid_start.add_child(instance)

func clear_drop_preview():
	for i in GRID_SIZE:
#		grid.get_child(i).modulate = Color.WHITE
		if grid.get_child(i).is_occupied:
			grid.get_child(i).modulate = Color.ORANGE
		else:
			grid.get_child(i).modulate = Color.WHITE
