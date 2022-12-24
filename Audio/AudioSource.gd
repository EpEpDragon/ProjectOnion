extends AudioStreamPlayer3D

const VOLUME = 0

@export var player : CharacterBody3D

func _ready():
	AudioHandler.add_audio_source(self)
	play(19)
