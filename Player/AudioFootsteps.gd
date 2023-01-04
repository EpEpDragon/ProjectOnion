extends AudioSource
@onready var player = $"../../"

func play_stream(stream : int = 0) -> void:
	
	if stream < 4:
		self.pitch_scale = (randf_range(0.9,1.2))
		super.play_stream(randi()%4)
	else:
		super.play_stream(stream)
