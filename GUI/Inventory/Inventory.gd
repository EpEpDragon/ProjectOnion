extends Control

const CELL_SIZE = 80
const GRID_W = 10
const GRID_H = 5
const GRID_SIZE = GRID_W*GRID_H

var item = preload("res://GUI/Inventory/InventoryItem.tscn")
var items : Dictionary = {"Stick" : Vector2(0,0)}
var dragging = false
#	set(value):
#		dragging = value
#		if dragging:
#			grid_start.mouse_filter = MOUSE_FILTER_PASS
#		else:
#			grid_start.mouse_filter = MOUSE_FILTER_STOP

@onready var inventroy_grid : GridContainer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer/InventoryGrid
@onready var item_layer : CanvasLayer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Spacer/CanvasLayer
@onready var grid_start = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Spacer/CanvasLayer/GridStart

func _set(property, value):
	match property:
		"visible":
			visible = value
			item_layer.visible = value


func _ready():
	add_item(Vector2(5,2), Vector2(3,2))


func add_item(grid_position := Vector2.ZERO, dimentions := Vector2.ONE) -> void:
	var instance = item.instantiate()
	instance.grid_position = grid_position
	instance.position = grid_position * CELL_SIZE + Vector2(4,10)
	instance.dimentions = dimentions
	instance.custom_minimum_size = dimentions*CELL_SIZE - Vector2(6,6)
	for x in dimentions.x:
		for y in dimentions.y:
			inventroy_grid.get_child(grid_position.x*grid_position.y + x + y*GRID_W).is_occupied = true
	grid_start.add_child(instance)
