extends Control
@export var player : CharacterBody3D

@onready var reverb_effect : AudioEffectReverb = AudioServer.get_bus_effect(1,0)
@onready var pan_effect : AudioEffectPanner = AudioServer.get_bus_effect(1,1)

@onready var camera : Camera3D = $SubViewport/DebugCam
@onready var volume_label = $"../VBoxContainer/Voume"
@onready var room_size_label = $"../VBoxContainer/RoomSize"
@onready var room_integrity_label = $"../VBoxContainer/RoomIntegrity"
@onready var wet_label = $"../VBoxContainer/WetLabel"
@onready var pan_label = $"../VBoxContainer/Pan"

func _ready():
	volume_label.set_self_modulate(Color.RED)
	room_size_label.set_self_modulate(Color.RED)
	room_integrity_label.set_self_modulate(Color.RED)
	wet_label.set_self_modulate(Color.RED)
	pan_label.set_self_modulate(Color.RED)

func _process(_delta):
	camera.position = player.position
	camera.position.y = 1.7
	camera.rotation.y = player.rotation.y
	volume_label.set_text("Volume: %.2fdB" % player.volume)
	room_size_label.set_text("Size: %.2fm (%.2f)" % [player.average_room_size, reverb_effect.room_size])
	room_integrity_label.set_text("Integrity: %.2f" % player.average_room_integrity)
	wet_label.set_text("Wet: %.2f" % reverb_effect.get_wet())
	pan_label.set_text("Pan: %.2f" % pan_effect.get_pan())
