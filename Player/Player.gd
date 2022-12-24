extends CharacterBody3D

const MAX_SPEED = 3.0
const MAX_SPEED_SPRINT = 6.0
const ACCELERATION = 50.0
const ACCELERATION_AIR = 3.0
const JUMP_VELOCITY = 4.5
const LOOK_SENS = 0.2

# Escape menu reference
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

var free_cam = false

func _ready():
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
