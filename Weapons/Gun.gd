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
var target_bob_position = Vector3.ZERO

@export var sight_time := 0.2
@export var shot_cooldown := 0.1
@export var return_rate := 5.0
@export var snappiness := 10.0

@onready var camera := $"../"
@onready var base_camera_position = camera.position
@onready var base_position = position
@onready var target_position = base_position

@onready var shot_timer := $ShotCooldownTimer
@onready var gun_sounds = $GunSounds
@onready var ray_cast := $RayCast3D

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
	target_rotation = lerp(target_rotation, Vector3.ZERO, return_rate*delta)
	set_rotation(Vector3(lerp(rotation, target_rotation, snappiness*delta)))
	set_position(Vector3(lerp(position, target_position + target_bob_position, snappiness*delta)))


func _fire():
	print(ray_cast.get_collider())
	tween_bolt.play()
	gun_sounds.pitch_scale = randf_range(0.9,1.1)
	gun_sounds.play()
	target_rotation += Vector3(deg_to_rad(randf_range(3,5)), deg_to_rad(randf_range(-3,3)), deg_to_rad(randf_range(-10,10)))

# Shot timer
func _on_timer_timeout():
	if shooting:
		_fire()
	if shooting:
		shot_timer.start(shot_cooldown)

func look_rotate(relative):
	set_rotation(Vector3(lerp(rotation.x, -relative.y, 0.0005), lerp(rotation.y, -relative.x, 0.0005), rotation.z))

func sight_in():
	target_position = Vector3(0,-0.076,base_position.z)
#	tween_sight_out.stop()
#	tween_sight_in.play()

func sight_out():
	target_position = base_position
#	tween_sight_in.stop()
#	tween_sight_out.play()
