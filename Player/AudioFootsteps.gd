extends AudioStreamPlayer3D

func play(from_position = 0.0) -> void:
	set_pitch_scale(randf_range(0.9,1.1))
	play()
