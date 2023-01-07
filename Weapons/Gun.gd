extends Node3D
class_name Gun

var shooting := false : 
	set(value):
		shooting = value
		if shooting:
			if not shot_timer.get_time_left():
				_fire()
				shot_timer.start(shot_cooldown)

var target_rotation = Vector3.ZERO
var base_rotation = Vector3.ZERO
var target_bob_position = Vector3.ZERO
var is_sight_in = false

# TODO Fix all this variable barf
@export var sight_time := 0.2
@export var rate_of_fire := 800.0
var shot_cooldown := 60.0/rate_of_fire
@export var return_rate := 5.0
@export var snappiness := 10.0

@onready var camera := $"../"
@onready var base_camera_position = camera.position
@onready var base_position = position
@onready var target_position = base_position

@onready var shot_timer := $ShotCooldownTimer
@onready var muscle_twitch_timer : Timer = $"../../MuscleTwitchTimer"
@onready var gun_sounds = $GunSounds
@onready var ray_cast := $RayCast3D
@onready var muzzel_flash : MeshInstance3D = $MuzzelFlash
@onready var timer_flash := $FlashTimer

@onready var tween_bolt = create_tween()
@onready var tween_sight_in = create_tween()
@onready var tween_sight_out = create_tween()

func _ready():
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
	target_rotation = lerp(target_rotation, base_rotation, return_rate*delta)
	set_rotation(lerp(rotation, target_rotation,snappiness*delta))
	set_position(lerp(position, target_position + target_bob_position, snappiness*delta))


func _fire():
	print(ray_cast.get_collider())
	muzzel_flash.mesh.material.set_shader_parameter("uv1_offset", Vector3(randf(),0.0,0.0))
	muzzel_flash.visible = true
	
	timer_flash.start(0.02)
	tween_bolt.play()
	gun_sounds.pitch_scale = randf_range(0.9,1.2)
	gun_sounds.play()
	
	if is_sight_in:
		target_rotation += Vector3(deg_to_rad(randf_range(1,2)), deg_to_rad(randf_range(-1,1)), deg_to_rad(randf_range(-3,3)))
	else:
		target_rotation += Vector3(deg_to_rad(randf_range(2,3)), deg_to_rad(randf_range(-2,2)), deg_to_rad(randf_range(-5,5)))


func look_rotate(relative):
	if is_sight_in:
		set_rotation(Vector3(lerp(rotation.x, -relative.y, 0.0002), lerp(rotation.y, -relative.x, 0.0001), rotation.z))
	else:
		set_rotation(Vector3(lerp(rotation.x, -relative.y, 0.0005), lerp(rotation.y, -relative.x, 0.0002), rotation.z))


func sight_in():
	if not $"../../../".sprint:
		is_sight_in = true
		base_rotation = Vector3.ZERO
		target_position = Vector3(0,-0.076,base_position.z)


func sight_out():
	is_sight_in = false
	if $"../../../".sprint:
		base_rotation = Vector3(deg_to_rad(-11), deg_to_rad(12.5), 0)
	target_position = base_position


# Shot timer
func _on_timer_timeout():
	if shooting:
		_fire()
	if shooting:
		shot_timer.start(shot_cooldown)


func _on_muscle_twitch_timer_timeout():
	target_rotation += Vector3(randf_range(-0.002,0.002), randf_range(-0.002,0.002), randf_range(-0.002,0.002))
	muscle_twitch_timer.start(randf_range(0.05,0.1))


func _on_flash_timer_timeout():
	muzzel_flash.visible = false
