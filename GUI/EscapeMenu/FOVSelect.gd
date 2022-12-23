extends HBoxContainer
@export_node_path(CharacterBody3D) var player_path

@onready var player = get_node(player_path)
@onready var fov_display : Label = $FOVContainer2/FOVValue
@onready var fov_slider : Slider = $FOVContainer2/FOVSelect

func _ready():
	fov_slider.value_changed.connect(_update_value_diplay)
	fov_slider.value = player.get_camera().get_fov()
	fov_display.set_text(str(fov_slider.value))


func _update_value_diplay(value):
	player.get_camera().set_fov(value)
	fov_display.set_text(str(value))
