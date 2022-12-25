extends Node3D

@export var pan_strength_curve : Curve
@export var pan_correction_curve : Curve
@export var wet_correction_curve : Curve

@onready var player = $"/root/World/Player"
@onready var camera = $"/root/World/Player/Body/Camera" #player.get_camera()

##################### Audio ######################
const REVERB_RAYS = 500
const REVERB_SAMPLES = 30
const REVERB_RAY_LENGTH = 20

@onready var state_space := get_world_3d().direct_space_state
@onready var pan_effect : AudioEffectPanner = AudioServer.get_bus_effect(1,0)
@onready var reverb_effect : AudioEffectReverb = AudioServer.get_bus_effect(1,1)

# TODO Makes some of these private
var audio_sources : Array[AudioStreamPlayer3D]
var volume : float = 0.0 # in dB
var room_size_samples : PackedFloat32Array
var room_integrity_samples : PackedFloat32Array
var room_bounce_vector_samples : PackedVector3Array
var average_room_size : float = 0.0 # In m
var average_room_integrity : float = 0.0 # Fraction
var wet : float = 0.0 # Reverb fraction heard
var average_room_bounce_vector := Vector3.ZERO
var lr_room_mix : float = 0.0 # Left right balance adjustment due to geometry
# DEBUG
var debug_audio_line = DebugDraw.new_lines(Vector3.ZERO, Color.GREEN)
var debug_audio_line_block = DebugDraw.new_lines(Vector3.ZERO, Color.RED)
var debug_room_sample_cloud = DebugDraw.new_point_cloud(Vector3.ZERO, 10, Color.RED)
var debug_room_size
var debug_bounce_vector

#################################################


func _ready():
	room_size_samples.resize(REVERB_SAMPLES)
	room_integrity_samples.resize(REVERB_SAMPLES)
	room_bounce_vector_samples.resize(REVERB_SAMPLES)
	
	var yellow_transparent = Color.YELLOW
	yellow_transparent.a = 0.2
	debug_room_size = DebugDraw.new_spheres(Vector3.ZERO, 1.0, yellow_transparent)
	debug_bounce_vector = DebugDraw.new_spheres(Vector3.ZERO, 0.25, yellow_transparent)
	debug_room_sample_cloud.cloud.resize(REVERB_SAMPLES*REVERB_RAYS)
	debug_room_size.add_sphere(Vector3.ZERO)
	debug_bounce_vector.add_sphere(Vector3.ZERO)
	debug_bounce_vector.construct()
	debug_room_size.construct()


func _process(_delta):
	occlude_audio()
	sample_room_reverb()

func occlude_audio():
	for source in audio_sources:
#		debug_audio_line.clear()
#		debug_audio_line_block.clear()
		volume = source.VOLUME
		
		var tangent = (player.global_position-source.global_position).cross(Vector3.UP).normalized()
		var tangent_up = tangent.cross(player.global_position-source.global_position).normalized()
		var check_points = [Vector3.ZERO, tangent*0.8, -tangent*0.8, tangent_up*0.8, -tangent_up*0.8]
		for from in check_points:
			for to in check_points:
				if state_space.intersect_ray(PhysicsRayQueryParameters3D.create(source.global_position + from, player.global_position+Vector3.UP*0.5 + to, player.collision_mask, [player.get_rid()])):
					volume -= 0.5
#					debug_audio_line_block.add_points(PackedVector3Array([source.global_position + from, player.global_position+Vector3.UP*0.5 + to]))
#				else:
#					debug_audio_line.add_points(PackedVector3Array([source.global_position + from, player.global_position+Vector3.UP*0.5 + to]))
		source.set_volume_db(volume)
		source.set_panning_strength(pan_strength_curve.sample(wet))
	
#	debug_audio_line.construct()
#	debug_audio_line_block.construct()


var sample_n = 0
func sample_room_reverb():
	# Room size estimate based on this frame's batch of rays 
	var current_sample_room_size : float = 0.0
	# Room integrity estimate based on this frame's batch of rays
	var current_sample_room_integrity : float = REVERB_RAYS
	# Ray cast points to use this frame
	var points := rand_points_on_sphere(REVERB_RAYS)
	# Vector of most audio bounce
	var current_room_bounce_vector := Vector3.ZERO
	
	# Cast rays to sample room size and integrity
	for i in REVERB_RAYS:
		var result = state_space.intersect_ray(PhysicsRayQueryParameters3D.create(player.global_position, points[i]*REVERB_RAY_LENGTH + player.global_position))
		if result:
			current_sample_room_size += player.global_position.distance_to(result.position)
			current_room_bounce_vector += (result.position - player.global_position).normalized()*Vector2(result.normal.x, result.normal.z).length()
			
#			debug_room_sample_cloud.cloud[i + REVERB_RAYS*sample_n] = result.position
		else:
			current_sample_room_integrity -= 1
			current_sample_room_size += REVERB_RAY_LENGTH
	current_sample_room_size /= REVERB_RAYS
	current_room_bounce_vector /= REVERB_RAYS
#	print(current_room_bounce_vector)
	current_sample_room_integrity /= REVERB_RAYS
	
	# Add current frame's samples to running averages
	room_size_samples[sample_n] = current_sample_room_size
	room_integrity_samples[sample_n] = current_sample_room_integrity
	room_bounce_vector_samples[sample_n] = current_room_bounce_vector
	sample_n = wrapi(sample_n + 1, 0, REVERB_SAMPLES)
	
	# Calculate averages
	average_room_size = 0
	average_room_integrity = 0
	for i in REVERB_SAMPLES:
		average_room_size += room_size_samples[i]
		average_room_integrity += room_integrity_samples[i]
		average_room_bounce_vector += room_bounce_vector_samples[i]
	average_room_size /= REVERB_SAMPLES
	average_room_integrity /= REVERB_SAMPLES
	average_room_bounce_vector /= REVERB_SAMPLES
	
	# DEBUG
	debug_room_size.mesh.set_radius(average_room_size)
	debug_room_size.mesh.set_height(2*average_room_size)
	debug_room_size.mat.albedo_color = Color(1,0,0,0.5).lerp(Color(0,0,1,0.1), average_room_size/REVERB_RAY_LENGTH)
	debug_room_size.position = player.global_position
	debug_bounce_vector.position = Vector3(average_room_bounce_vector.x, 0, average_room_bounce_vector.z)*10 + player.global_position
	
	reverb_effect.set_room_size(average_room_size/REVERB_RAY_LENGTH)
	# TODO Scale wet to sound right
#	wet = pow(100,average_room_integrity-1)
	wet = wet_correction_curve.sample(average_room_integrity)
	reverb_effect.set_wet(wet)
	
	# Pan correction
	var pan = player.basis.x.dot(average_room_bounce_vector)*0.8
	if pan >= 0:
		pan_effect.set_pan(pan_correction_curve.sample(pan))
	else:
		pan_effect.set_pan(-pan_correction_curve.sample(-pan))
#	debug_room_sample_cloud.construct()
	debug_bounce_vector.construct()


func rand_points_on_sphere(n : int) -> PackedVector3Array:
	var points := PackedVector3Array([])
	points.resize(n)
	for i in range(n):
		while points[i] == Vector3.ZERO:
			points[i] = Vector3(randi()-0x80000000, randi()-0x80000000, randi()-0x80000000).normalized()
			if points[i] == Vector3.ZERO:
				print("ZERO VECTOR")
	return points


func inverse_linear(vec : Vector3) -> Vector3:
	for i in 3:
		if vec[i] >= 0:
			vec[i] = (-vec[i] + REVERB_RAY_LENGTH)
		else:
			vec[i] = (-vec[i] - REVERB_RAY_LENGTH)
	return vec

func add_audio_source(source : AudioStreamPlayer3D):
	audio_sources.append(source)
