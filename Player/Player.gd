extends CharacterBody3D

const MAX_SPEED = 3.0
const MAX_SPEED_SPRINT = 6.0
const ACCELERATION = 50.0
const ACCELERATION_AIR = 3.0
const JUMP_VELOCITY = 4.5
const LOOK_SENS = 0.2

# Escape menu reference
#@export_node_path(Control) var escape_menu_path
@export var escape_menu : Control

@onready var PHYSICS_FPS = Engine.physics_ticks_per_second
@onready var camera : Camera3D = $Body/Camera
@onready var body : MeshInstance3D = $Body
@onready var camera_offset = camera.position

# Movement
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target_direction = Vector3()
var sprint = false

# GUI
var in_menu = false

###################### Audio ######################
#const REVERB_RAYS = 500
#const REVERB_SAMPLES = 30
#const REVERB_RAY_LENGTH = 20
#
#@onready var state_space := get_world_3d().direct_space_state
#@onready var pan_effect : AudioEffectPanner = AudioServer.get_bus_effect(1,0)
#@onready var reverb_effect : AudioEffectReverb = AudioServer.get_bus_effect(1,1)
#
## TODO Makes some of these private
#var audio_sources : Array[AudioStreamPlayer3D]
#var volume : float = 0.0 # in dB
#var room_size_samples : PackedFloat32Array
#var room_integrity_samples : PackedFloat32Array
#var room_bounce_vector_samples : PackedVector3Array
#var average_room_size : float = 0.0 # In m
#var average_room_integrity : float = 0.0 # Fraction
#var average_room_bounce_vector := Vector3.ZERO
#var lr_room_mix : float = 0.0 # Left right balance adjustment due to geometry
## DEBUG
#var audio_line = DebugDraw.new_lines(Vector3.ZERO, Color.GREEN)
#var audio_line_block = DebugDraw.new_lines(Vector3.ZERO, Color.RED)
#var room_sample_cloud = DebugDraw.new_point_cloud(Vector3.ZERO, 10, Color.RED)
#var bounce_vector = DebugDraw.new_spheres(Vector3.ZERO, 0.25, Color.YELLOW)
##################################################

var free_cam = false

func _ready():
#	room_size_samples.resize(REVERB_SAMPLES)
#	room_integrity_samples.resize(REVERB_SAMPLES)
#	room_bounce_vector_samples.resize(REVERB_SAMPLES)
#	room_sample_cloud.cloud.resize(REVERB_SAMPLES*REVERB_RAYS)
#	bounce_vector.add_sphere(Vector3.ZERO)
#	bounce_vector.construct()
	
	print("PHYSICS_FPS: ", PHYSICS_FPS)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event):
	if event is InputEventMouseMotion and !in_menu:
		if !free_cam:
			camera.rotation.x = clamp(camera.rotation.x + -event.relative.y*0.01*LOOK_SENS, -PI/2, PI/2)
			rotation.y += -event.relative.x*0.01*LOOK_SENS
		else:
			camera.rotation.x = clamp(camera.rotation.x + -event.relative.y*0.01*LOOK_SENS, -PI/2, PI/2)
			camera.rotation.y += -event.relative.x*0.01*LOOK_SENS


func _input(event):
	if event.is_action_pressed("sprint"): 
		sprint = true
	elif event.is_action_released("sprint"): 
		sprint = false
	elif event.is_action_pressed("menu"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			in_menu = true
			escape_menu.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			in_menu = false
			escape_menu.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("free_cam"):
		free_cam = !free_cam
		camera.position = camera_offset
		camera.rotation = Vector3.ZERO


func _physics_process(delta):
	if !free_cam:
		character_movement(delta)
#		occlude_audio()
#		sample_room_reverb()


func _process(delta):
	if !free_cam:
		fix_jitter(delta)
	else:
		free_cam_movement(delta)


func character_movement(delta):
	# Add gravity acceleration.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Pick grounded or in air acceleration
	var acceleration
	if is_on_floor():
		acceleration = ACCELERATION * delta
	else:
		acceleration = ACCELERATION_AIR * delta
	
	# Apply acceleration
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	target_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if target_direction:
		velocity.x += target_direction.x * acceleration
		velocity.z += target_direction.z * acceleration
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration)
		velocity.z = move_toward(velocity.z, 0, acceleration)
	
	# Clamp horizontal velocity to max speed
	var max_speed = MAX_SPEED
	if sprint: max_speed = MAX_SPEED_SPRINT
	
	if velocity.x*velocity.x + velocity.z*velocity.z > max_speed*max_speed:
		var direction = Vector2(velocity.x, velocity.z).normalized()
		velocity.x = direction.x * max_speed
		velocity.z = direction.y * max_speed
	
	move_and_slide()


func free_cam_movement(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if Input.is_action_pressed("jump"):
		input_dir = Vector3(input_dir.x, 1, input_dir.y)
	elif Input.is_action_pressed("sprint"):
		input_dir = Vector3(input_dir.x, -1, input_dir.y)
	else: 
		input_dir = Vector3(input_dir.x, 0, input_dir.y)
	
	camera.position += camera.transform.basis * input_dir * MAX_SPEED * delta

#
#func occlude_audio():
#	for source in audio_sources:
#		audio_line.clear()
#		audio_line_block.clear()
#		volume = source.VOLUME
#
#		var tangent = (camera.global_position-source.global_position).cross(Vector3.UP).normalized()
#		var tangent_up = tangent.cross(camera.global_position-source.global_position).normalized()
#		var check_points = [Vector3.ZERO, tangent*0.8, -tangent*0.8, tangent_up*0.8, -tangent_up*0.8]
#		for from in check_points:
#			for to in check_points:
#				if state_space.intersect_ray(PhysicsRayQueryParameters3D.create(source.global_position + from, camera.global_position + to, collision_mask, [get_rid()])):
#					volume -= 0.5
#					audio_line_block.add_points(PackedVector3Array([source.global_position + from, camera.global_position + to]))
#				else:
#					audio_line.add_points(PackedVector3Array([source.global_position + from, camera.global_position + to]))
#		source.set_volume_db(volume)
#
#	audio_line.construct()
#	audio_line_block.construct()


#var sample_n = 0
#func sample_room_reverb():
#	# Room size estimate based on this frame's batch of rays 
#	var current_sample_room_size : float = 0.0
#	# Room integrity estimate based on this frame's batch of rays
#	var current_sample_room_integrity : float = REVERB_RAYS
#	# Ray cast points to use this frame
#	var points := rand_points_on_sphere(REVERB_RAYS)
#	# Vector of most audio bounce
#	var current_room_bounce_vector := Vector3.ZERO
#
#	# Cast rays to sample room size and integrity
#	for i in REVERB_RAYS:
#		var result = state_space.intersect_ray(PhysicsRayQueryParameters3D.create(global_position, points[i]*REVERB_RAY_LENGTH + global_position))
#		if result:
#			current_sample_room_size += global_position.distance_to(result.position)
#			current_room_bounce_vector += inverse_linear(result.position - global_position)*Vector2(result.normal.x, result.normal.z).length()
#
#			room_sample_cloud.cloud[i + REVERB_RAYS*sample_n] = result.position
#		else:
#			current_sample_room_integrity -= 1
#			current_sample_room_size += REVERB_RAY_LENGTH
#	current_sample_room_size /= REVERB_RAYS
#	current_room_bounce_vector /= REVERB_RAYS
#	current_sample_room_integrity /= REVERB_RAYS
#
#	# Add current frame's samples to running averages
#	room_size_samples[sample_n] = current_sample_room_size
#	room_integrity_samples[sample_n] = current_sample_room_integrity
#	room_bounce_vector_samples[sample_n] = current_room_bounce_vector
#	sample_n = wrapi(sample_n + 1, 0, REVERB_SAMPLES)
#
#	# Calculate averages
#	average_room_size = 0
#	average_room_integrity = 0
#	for i in REVERB_SAMPLES:
#		average_room_size += room_size_samples[i]
#		average_room_integrity += room_integrity_samples[i]
#		average_room_bounce_vector += room_bounce_vector_samples[i]
#	average_room_size /= REVERB_SAMPLES
#	average_room_integrity /= REVERB_SAMPLES
#	average_room_bounce_vector /= REVERB_SAMPLES
#
#	bounce_vector.position = Vector3(average_room_bounce_vector.x, 0, average_room_bounce_vector.z) + global_position
#
#
#	reverb_effect.set_room_size(average_room_size/REVERB_RAY_LENGTH)
#	# TODO Scale wet to sound right
#	reverb_effect.set_wet(pow(100,average_room_integrity-1))
#	pan_effect.set_pan(basis.x.dot(average_room_bounce_vector/REVERB_RAY_LENGTH)*2)
#
#	room_sample_cloud.construct()
#	bounce_vector.construct()

#
#func rand_points_on_sphere(n : int) -> PackedVector3Array:
#	var points := PackedVector3Array([])
#	points.resize(n)
#	for i in range(n):
#		while points[i] == Vector3.ZERO:
#			points[i] = Vector3(randi()-0x80000000, randi()-0x80000000, randi()-0x80000000).normalized()
#			if points[i] == Vector3.ZERO:
#				print("ZERO VECTOR")
#	return points


#func inverse_linear(vec : Vector3) -> Vector3:
#	for i in 3:
#		if vec[i] >= 0:
#			vec[i] = (-vec[i] + REVERB_RAY_LENGTH)
#		else:
#			vec[i] = (-vec[i] - REVERB_RAY_LENGTH)
#	return vec


func fix_jitter(delta) -> void:
	var fps = Engine.get_frames_per_second()
	if fps > PHYSICS_FPS:
		body.set_as_top_level(true)
		var lerp_pos = global_transform.origin + target_direction / fps
		body.global_transform.origin = body.global_transform.origin.lerp(lerp_pos, 20 * delta)
		body.rotation.y = rotation.y
	else:
		body.set_as_top_level(false)


func get_camera():
	return camera

## TODO Make this better
#func add_audio_source(source : AudioStreamPlayer3D):
#	audio_sources.append(source)
