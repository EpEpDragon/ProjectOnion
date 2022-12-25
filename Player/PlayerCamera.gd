extends Camera3D

const BOB_DISTANCE = 0.04
const BOB_TIME = 0.18
const RUN_MULTIPLE = 1.4

@onready var player := $"../../"
@onready var audio_footsteps := $"../AudioFootsteps"
@onready var walk_tween := create_tween()
@onready var stop_tween := create_tween()
@onready var base_position = position

var walk = false

func _ready():
	tween_setup()
	set_fov(Settings.fov)

func _process(delta):
	if player.sprint:
		walk_tween.set_speed_scale(RUN_MULTIPLE)
	else:
		walk_tween.set_speed_scale(1)
	if walk:
		stop_tween.stop()
		walk_tween.play()
	else:
		walk_tween.stop()
		stop_tween.play()

func tween_setup():
	walk_tween.stop()
	stop_tween.stop()
	
	# Camera bob loop
	walk_tween.set_loops()
	walk_tween.set_parallel()
	walk_tween.tween_property(self, "position:x", base_position.x + BOB_DISTANCE, BOB_TIME)
	walk_tween.tween_property(self, "position:y", base_position.y - BOB_DISTANCE, BOB_TIME)
	walk_tween.tween_callback(audio_footsteps.play)
	walk_tween.chain()
	walk_tween.tween_property(self, "position:y", base_position.y + BOB_DISTANCE, BOB_TIME)
	walk_tween.chain()
	walk_tween.tween_property(self, "position:x", base_position.x - BOB_DISTANCE, BOB_TIME)
	walk_tween.tween_property(self, "position:y", base_position.y - BOB_DISTANCE, BOB_TIME)
	walk_tween.tween_callback(audio_footsteps.play)
	walk_tween.chain()
	walk_tween.tween_property(self, "position:y", base_position.y + BOB_DISTANCE, BOB_TIME)
	
	# Return to center
	stop_tween.set_loops()
	stop_tween.tween_property(self, "position", base_position, BOB_TIME)
