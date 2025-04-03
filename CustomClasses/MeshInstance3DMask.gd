extends MeshInstance3D
## MeshInstance3D with additional mask generation logic for shaders
class_name MeshInstance3DOnion



@onready var player := %Player

func _ready():
	# Add masking mesh
	var mask_mesh := MeshInstance3DMask.new()
	add_child(mask_mesh)



## Mesh instance used to write screen space stable position mask to visibility layer 20
class MeshInstance3DMask extends MeshInstance3D:
	var pos_mask_shader = load("res://Materials/ObjScreenPositionMask.gdshader")
	var material : ShaderMaterial
	@onready var player : PlayerCharacter = get_tree().get_nodes_in_group("player")[0]
	
	func _ready():
		# Duplicate parent mesh
		mesh = get_parent().mesh.duplicate()
		# Apply mask material
		material = ShaderMaterial.new()
		mesh.surface_set_material(0, material)
		material.shader = pos_mask_shader
		# Scale down slightly to not be visible
		scale = Vector3(0.9999, 0.9999, 0.9999)
		# Set correct visibility maske for shader
		set_layer_mask_value(20, true)
		
	#var i = 0
	func _process(delta):
		#i+=1
		# Send screen position to shader every frame
		var pos = player.camera.unproject_position(global_position)
		#if i%10 == 0:
			#print(get_parent().name,pos)
			#i = 0
		material.set_shader_parameter("object_screen_position", pos)
