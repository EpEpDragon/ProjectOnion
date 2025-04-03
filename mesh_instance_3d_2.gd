extends MeshInstance3D

@onready var material : ShaderMaterial = get_active_material(0)

func _process(delta):
	material.set_shader_parameter("object_screen_position", %Player.camera.unproject_position(global_position))
