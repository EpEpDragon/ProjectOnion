extends Camera3D
@export var player : PlayerCharacter
@onready var player_camera = player.camera

# Set camera proporties equal to player camera
func _process(delta):
	global_position = player_camera.global_position
	global_rotation = player_camera.global_rotation
	fov = player_camera.fov
