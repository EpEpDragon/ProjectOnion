extends MeshInstance3D

const BOB_DISTANCE = 0.03
const BOB_TIME = 0.8
const RUN_MULTIPLE = 1.3

var walk = false
var local_pos = position
@onready var gun := $Camera/Gun
@onready var player : PlayerCharacter = $"../"
@onready var audio_footsteps := $"AudioFootsteps"
@onready var walk_tween := create_tween()
@onready var stop_tween := create_tween()
@onready var base_position = position

var just_walking = false

func _ready():
	tween_setup()

# TODO Make walk and sprinting checks not in process
func _process(_delta):
	if player.is_sprinting:
		walk_tween.set_speed_scale(RUN_MULTIPLE)
	else:
		walk_tween.set_speed_scale(1)
	if walk:
		stop_tween.stop()
		walk_tween.play()
		just_walking = true
	elif just_walking:
		walk_tween.stop()
		stop_tween.play()
		just_walking = false

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
	stop_tween.tween_property(self, "local_pos", base_position, BOB_TIME/3)
	stop_tween.parallel().tween_property(gun, "target_bob_position", Vector3.ZERO, BOB_TIME/3)
	stop_tween.tween_callback(audio_footsteps.play_stream)
	stop_tween.tween_callback(stop_tween.stop)

func bob(t : float, x_max : float, y_max : float):
	# Camera bob
	local_pos = base_position + Vector3(x_max*sin(t), y_max*sin(2*t), 0)
	# Gun bob
	if player.is_sprinting:
		gun.target_bob_rotation = Vector3(randf_range(0,3)*sin(2*t), randf_range(0,3)*sin(2*t), 5*sin(t))
		gun.target_bob_position = Vector3(x_max*sin(t), y_max*sin(2*t), 0)*0.4
	else:
		gun.target_bob_rotation = Vector3(0.5*sin(2*t), 0.5*sin(2*t), 3*sin(t))
		gun.target_bob_position = Vector3(x_max*sin(t), y_max*0.5*sin(2*t), 0)*0.2
