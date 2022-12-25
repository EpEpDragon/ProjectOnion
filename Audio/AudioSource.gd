extends AudioStreamPlayer3D

@onready var VOLUME = volume_db

#@onready var player = $"/root/World/Player"

func _ready():
	AudioHandler.add_audio_source(self)
