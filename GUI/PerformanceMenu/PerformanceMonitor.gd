extends Control

@export var player : CharacterBody3D

@onready var fps : Label = $FPS
@onready var frame_time : Label = $FrameTime

func _process(delta):
#	set_text(str(Performance.get_monitor(Performance.TIME_FPS)))
	fps.set_text(str(round(1/delta)))
#	frame_time.set_text("%.2f" % player.duration)
