extends Control

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
	visible = false
	add_item(Vector2i(0,0), Vector2i(3,2))
	add_item(Vector2i(4,3), Vector2i(1,2))
	add_item(Vector2i(1,2), Vector2i(1,1))


func add_item(grid_position := Vector2i.ZERO, dimentions := Vector2i.ONE) -> void:
	var instance = item.instantiate()
	instance.grid_position = grid_position
	instance.dimentions = dimentions
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
