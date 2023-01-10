extends CharacterBody3D
class_name PlayerCharacter

const MAX_SPEED = 3.5
const MAX_SPEED_SPRINT = 6
const ACCELERATION = 50.0
const ACCELERATION_AIR = 3.0
const JUMP_VELOCITY = 4.5
const LOOK_SENS = 0.2


@onready var PHYSICS_FPS = Engine.physics_ticks_per_second
@onready var camera : Camera3D = $Body/Camera
@onready var body : MeshInstance3D = $Body
@onready var base_camera_position = camera.position
@onready var gun : Gun = $Body/Camera/Gun

# Movement
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target_direction = Vector3()

# TODO Make sprint and sight in work well together
# probably by using some kind of point aim while sprinting, i.e. should be able to shoot
# and aim while sprinting.
var is_sprinting = false :
	set(value):
		is_sprinting = value
		# Update sight in position
		if Input.is_action_pressed("fire_secondary"):
			gun.sight_in()
		else:
			gun.sight_out()

# GUI
var free_cam = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Character control input
func _unhandled_input(event):
	if event is InputEventMouseMotion:
#		if !free_cam:
		camera.rotation.x = clamp(camera.rotation.x + -event.relative.y*0.01*LOOK_SENS, -PI/2, PI/2)
		rotation.y += -event.relative.x*0.01*LOOK_SENS
		gun.look_rotate(event.relative)
#		else:
#			camera.rotation.x = clamp(camera.rotation.x + -event.relative.y*0.01*LOOK_SENS, -PI/2, PI/2)
#			camera.rotation.y += -event.relative.x*0.01*LOOK_SENS
	elif event.is_action_pressed("sprint"): 
		is_sprinting = true
	elif event.is_action_released("sprint"): 
		is_sprinting = false
	elif event.is_action_pressed("fire_primary"):
		gun.shooting = true
	elif event.is_action_released("fire_primary"):
		gun.shooting = false
	elif event.is_action_pressed("fire_secondary"):
		gun.sight_in()
	elif event.is_action_released("fire_secondary"):
		gun.sight_out()

func _physics_process(delta):
	_character_movement(delta)


func _process(delta):
	_fix_jitter(delta)


func _character_movement(delta):
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
		$Body.walk = true
		velocity.x += target_direction.x * acceleration
		velocity.z += target_direction.z * acceleration
	else:
		$Body.walk = false
		velocity.x = move_toward(velocity.x, 0, acceleration)
		velocity.z = move_toward(velocity.z, 0, acceleration)
	
	# Clamp horizontal velocity to max speed
	var max_speed = MAX_SPEED
	if is_sprinting: max_speed = MAX_SPEED_SPRINT
	
	if velocity.x*velocity.x + velocity.z*velocity.z > max_speed*max_speed:
		var direction = Vector2(velocity.x, velocity.z).normalized()
		velocity.x = direction.x * max_speed
		velocity.z = direction.y * max_speed
	
	move_and_slide()


func _free_cam_movement(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if Input.is_action_pressed("jump"):
		input_dir = Vector3(input_dir.x, 1, input_dir.y)
	elif Input.is_action_pressed("sprint"):
		input_dir = Vector3(input_dir.x, -1, input_dir.y)
	else: 
		input_dir = Vector3(input_dir.x, 0, input_dir.y)
	
	camera.position += camera.transform.basis * input_dir * MAX_SPEED * delta


func _fix_jitter(delta) -> void:
	var fps = Engine.get_frames_per_second()
	if fps > PHYSICS_FPS:
		body.set_as_top_level(true)
		var lerp_pos = global_transform.origin + body.local_pos + target_direction / fps
		body.global_transform.origin = body.global_transform.origin.lerp(lerp_pos, 20 * delta)
		body.rotation.y = rotation.y
	else:
		body.set_as_top_level(false)


func get_camera():
	return $Body/Camera
