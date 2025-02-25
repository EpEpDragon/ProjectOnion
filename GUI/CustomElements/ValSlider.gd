@tool
extends Control

@export var text : String = "Label" : 
	set(value):
		text = value
		if $HBox/Label:
			$HBox/Label.set_text(value)
@export var initial_value : float = 0 :
	set(value):
		initial_value = value
		if $HBox/HBox2/ValueLabel:
			$HBox/HBox2/ValueLabel.set_text(str(value))
		if $HBox/HBox2/Slider:
			$HBox/HBox2/Slider.set_value(value)
@export var step : float = 1 :
	set(value):
		step = value
		if $HBox/HBox2/Slider:
			$HBox/HBox2/Slider.set_step(value)
@export var min_value : float = 0:
	set(value):
		min_value = value
		if $HBox/HBox2/Slider:
			$HBox/HBox2/Slider.set_min(min_value)
@export var max_value : float = 100:
	set(value):
		max_value = value
		if $HBox/HBox2/Slider:
			$HBox/HBox2/Slider.set_max(max_value)

@onready var slider : Slider = $HBox/HBox2/Slider
@onready var value_label : Label = $HBox/HBox2/ValueLabel

func _ready():
	slider.value_changed.connect(_update_value_display)

func _update_value_display(value):
	value_label.set_text(str(value))

func get_slider() -> HSlider :
	return slider

func get_value():
	return slider.get_value()

func set_value(value):
	slider.set_value(value)
