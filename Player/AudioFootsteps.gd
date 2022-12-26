extends AudioStreamPlayer3D
@onready var player = $"../../"
func play(from : float = 0.0) -> void:
	if player.sprint:
		set_pitch_scale(randf_range(0.7,0.8))
	else:
		set_pitch_scale(randf_range(0.5,0.6))
	
	play(from)

