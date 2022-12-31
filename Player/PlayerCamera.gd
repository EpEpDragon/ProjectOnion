extends Camera3D

const BOB_DISTANCE = 0.03
const BOB_TIME = 1.0
const RUN_MULTIPLE = 1.3

@onready var player := $"../../"
@onready var audio_footsteps := $"../AudioFootsteps"
@onready var walk_tween := create_tween()
@onready var stop_tween := create_tween()
@onready var base_position = position

var walk = false

func _ready():
	tween_setup()
	set_fov(Settings.fov)

func _process(_delta):
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
	walk_tween.set_loops()
	walk_tween.tween_method(bob.bind(BOB_DISTANCE*0.7,BOB_DISTANCE),0.0,PI/2,BOB_TIME/4)
	walk_tween.tween_callback(audio_footsteps.play_stream)
	walk_tween.tween_method(bob.bind(BOB_DISTANCE*0.7,BOB_DISTANCE),PI/2,PI*3/2,BOB_TIME/2)
	walk_tween.tween_callback(audio_footsteps.play_stream)
	walk_tween.tween_method(bob.bind(BOB_DISTANCE*0.7,BOB_DISTANCE),PI*3/2,2*PI,BOB_TIME/4)
	
	# Return to center
	stop_tween.set_loops()
	stop_tween.tween_property(self, "position", base_position, BOB_TIME)

func bob(t : float, x_max : float, y_max : float):
	var target_position = base_position + Vector3(x_max*sin(t), y_max*sin(2*t), 0)
#	position = lerp(position, target_position, 0.5)
	position = target_position
