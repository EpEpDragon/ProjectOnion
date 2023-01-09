extends Control

const MAX_RES = Vector2i(3440, 1440)

# Player ref
@onready var player = $"/root/World/Player"
# Environment ref
@onready var environment = $"/root/World/WorldEnvironment"

###### Video ######
# Fullscreen
@onready var fullscreen_button : CheckButton = $PanelContainer/MarginContainer/TabContainer/Video/Fullscreen
# Resolutuion scale
@onready var resolution_scale = $PanelContainer/MarginContainer/TabContainer/Video/ResolutionScale
# FOV
@onready var fov = $PanelContainer/MarginContainer/TabContainer/Video/FOV
# TAA
@onready var taa : CheckButton = $PanelContainer/MarginContainer/TabContainer/Video/TAA
@onready var ssao : CheckButton = $PanelContainer/MarginContainer/TabContainer/Video/SSAO
@onready var sdfgi : CheckButton = $PanelContainer/MarginContainer/TabContainer/Video/SDFGI

func _ready():
	fullscreen_button.toggled.connect(_fullscreen_toggle)
	
	resolution_scale.get_slider().value_changed.connect(_resolution_scale_change)
	
	fov.get_slider().value_changed.connect(_fov_select)
	fov.set_value(player.get_camera().get_fov())
	
	taa.toggled.connect(_taa_toggle)
	ssao.toggled.connect(_ssao_toggle)
	sdfgi.toggled.connect(_sdfgi_toggle)

func _fullscreen_toggle(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _resolution_scale_change(value):
	get_viewport().set_scaling_3d_scale(value/100)

func _fov_select(value):
	player.get_camera().set_fov(value)

func _taa_toggle(button_pressed):
	get_viewport().set_use_taa(button_pressed)

func _ssao_toggle(button_pressed):
	environment.get_environment().set_ssao_enabled(button_pressed)

func _sdfgi_toggle(button_pressed):
	environment.get_environment().set_sdfgi_enabled(button_pressed)
