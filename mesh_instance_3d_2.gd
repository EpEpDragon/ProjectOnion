extends MeshInstance3D

@onready var material : ShaderMaterial = get_active_material(0)

func _process(delta):
	var screen_pos : Vector2 = %Player.camera.unproject_position(global_position)
	material.set_shader_parameter("object_screen_position", screen_pos)
	#var time = Time.get_ticks_msec()/1000.0
	#global_position.x = sin(time)
	#global_position.y = cos(time)
	#global_position.z = cos(time)
