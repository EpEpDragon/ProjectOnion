extends Node3D
class_name Gun

var shooting := false : 
	set(value):
		shooting = value
		if shooting:
			if not shot_timer.get_time_left():
				_fire()
				shot_timer.start(shot_cooldown)
		elif player.is_sprinting and not Input.is_action_pressed("fire_secondary"):
			sight_out()

var target_rotation = Vector3.ZERO
var base_rotation = Vector3.ZERO
var target_position = Vector3.ZERO
var base_position = Vector3.ZERO
var target_bob_position = Vector3.ZERO
var target_bob_rotation = Vector3.ZERO
var is_sight_in = false

# TODO Fix all this variable barf
@export var sight_time := 0.2
@export var rate_of_fire := 800.0
var shot_cooldown := 60.0/rate_of_fire

@export var rotation_control := 5.0
@export var rotation_snappiness := 10.0
@export var position_control := 20.0
@export var position_snappiness := 25.0

@onready var player : PlayerCharacter = $"../../../"
@onready var camera := $"../"
@onready var camera_origin = camera.position
@onready var origin = position

@onready var shot_timer := $ShotCooldownTimer
@onready var muscle_twitch_timer : Timer = $"../../MuscleTwitchTimer"
@onready var gun_sounds = $GunSounds
@onready var ray_cast := $RayCast3D

@onready var tween_bolt = create_tween()
@onready var tween_sight_in = create_tween()
@onready var tween_sight_out = create_tween()

func _ready():
	base_position = origin
	tween_bolt.stop()
	tween_sight_in.stop()
	tween_sight_out.stop()
	
	# Bolt
	tween_bolt.set_loops()
	tween_bolt.tween_property($GunMesh/Bolt, "position:z", -0.5, shot_cooldown*0.3)
	tween_bolt.tween_property($GunMesh/Bolt, "position:z", -0.592, shot_cooldown*0.6)
	tween_bolt.tween_callback(tween_bolt.stop)
	
	# Sight in
	tween_sight_in.set_loops()
	tween_sight_in.parallel().tween_property(self, "position", Vector3(0,-0.076,base_position.z), sight_time)
	tween_sight_in.tween_callback(tween_sight_in.stop)
	
	# Sight out
	tween_sight_out.set_loops()
	tween_sight_out.parallel().tween_property(self, "position", base_position, sight_time)
	tween_sight_out.tween_callback(tween_sight_out.stop)


func _process(delta):
	target_rotation = lerp(target_rotation, base_rotation, rotation_control*delta)
	target_position = lerp(target_position, base_position, position_control*delta)
	set_rotation_degrees(lerp(rotation_degrees, target_rotation + target_bob_rotation,rotation_snappiness*delta))
	set_position(lerp(position, target_position + target_bob_position, position_snappiness*delta))

# TODO Add gun charactaristic exports
func _fire():
	if player.is_sprinting and not is_sight_in:
		sight_in()
#	print(ray_cast.get_collider())
	if ray_cast.get_collider() is RigidBody3D:
		print(ray_cast.get_collider())
		ray_cast.get_collider().apply_impulse((ray_cast.get_collision_point()-ray_cast.global_position).normalized()*0.5, ray_cast.get_collision_point()-ray_cast.get_collider().global_position)
	$MuzzelFlash.emitting = true;
	tween_bolt.play()
	gun_sounds.pitch_scale = randf_range(0.9,1.2)
	gun_sounds.play()
	
	# Z Recoil
	if player.is_sprinting:
		target_position += Vector3(0,0,0.07)
	else:
		target_position += Vector3(0,0,0.05)
	
	# Rotational recoil
	if is_sight_in:
		if player.is_sprinting:
			target_rotation += Vector3(randf_range(3,5), randf_range(-4,4), randf_range(-7,7))
		else:
			target_rotation += Vector3(randf_range(1,2), randf_range(-1,1), randf_range(-4,4))
	else:
		target_rotation += Vector3(randf_range(2,3), randf_range(-2,2), randf_range(-5,5))


func look_rotate(relative):
	if is_sight_in:
		set_rotation(Vector3(lerp(rotation.x, -relative.y, 0.0002), lerp(rotation.y, -relative.x, 0.0001), rotation.z))
	else:
		set_rotation(Vector3(lerp(rotation.x, -relative.y, 0.0005), lerp(rotation.y, -relative.x, 0.0002), rotation.z))


func sight_in():
	is_sight_in = true
	if player.is_sprinting:
		base_position = Vector3(0.025, -0.17, origin.z)
		base_rotation = Vector3(0.1,-2.8,18.3)
	else:
		base_position = Vector3(0,-0.076,origin.z)
		base_rotation = Vector3.ZERO


func sight_out():
	is_sight_in = false
	if player.is_sprinting:
		base_rotation = Vector3(-11, 12.5, 0)
	else:
		base_rotation = Vector3.ZERO
	base_position = origin


# Shot timer
func _on_timer_timeout():
	if shooting:
		_fire()
	if shooting:
		shot_timer.start(shot_cooldown)

# TODO Maybe make passive gun sway better
func _on_muscle_twitch_timer_timeout():
	target_rotation += Vector3(randf_range(-0.02,0.02), randf_range(-0.02,0.02), randf_range(-0.02,0.02))
	muscle_twitch_timer.start(randf_range(0.05,0.1))
