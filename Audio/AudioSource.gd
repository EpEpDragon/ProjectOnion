class_name AudioSource extends AudioStreamPlayer3D

var sources : Array[AudioStreamPlayer3D]

# WORKAROUND Typed array breaks inline set
@export var audio_streams : Array[AudioStream] : set = setter
func setter(value):
	audio_streams = value
	for s in audio_streams:
#		var key = s.resource_path.get_file()
		sources.append(AudioStreamPlayer3D.new())
		sources[-1].stream = s
		sources[-1].attenuation_model = attenuation_model
		sources[-1].volume_db = volume_db
		sources[-1].unit_size = unit_size
		sources[-1].max_db = max_db
		sources[-1].pitch_scale = pitch_scale
		sources[-1].max_distance = max_distance
		sources[-1].max_polyphony = max_polyphony
		sources[-1].panning_strength = panning_strength
		sources[-1].bus = bus
		add_child(sources[-1])

@export var use_occlusion = false :
	set(value):
		use_occlusion = value
		if (value):
			AudioHandler.add_audio_source(self)

@onready var VOLUME = volume_db

func _set(name, value):
	match name:
		"volume_db":
			volume_db = value
			for s in sources:
				s.volume_db = value
		"panning_strength":
			panning_strength = value
			for s in sources:
				s.panning_strength = value
		"pitch_scale":
			pitch_scale = value
			for s in sources:
				s.pitch_scale = value

func play_stream(stream : int = 0) -> void:
	sources[stream].play()
