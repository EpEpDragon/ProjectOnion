extends MeshInstance3D
class_name MeshInstance3DOnion

@onready var player := %Player

func _ready():
	var mask_mesh := MeshInstance3DMask.new()
	add_child(mask_mesh)
	#mask_mesh.mesh = mesh
	#mask_mesh.mesh.surface_set_material(0, pos_mask_shader_uid)
	#mask_mesh.scale = Vector3(0.9999, 0.9999, 0.9999)


class MeshInstance3DMask extends MeshInstance3D:
	var pos_mask_shader = load("res://Materials/ObjScreenPositionMask.gdshader")
	@onready var material : ShaderMaterial = get_active_material(0)
	@onready var player = get_tree().get_nodes_in_group("player")[0]
	
	func _ready():
		# Duplicate parent mesh
		mesh = get_parent().mesh
		# Apply mask material
		mesh.surface_set_material(0, pos_mask_shader)
		# Scale down slightly to not be visible
		scale = Vector3(0.9999, 0.9999, 0.9999)
		# Set correct visibility maske for shader
		set_layer_mask_value(20, true)
		
	func _process(delta):
		# Send screen position to shader every frame
		material.set_shader_parameter("object_screen_position", player.camera.unproject_position(global_position))
