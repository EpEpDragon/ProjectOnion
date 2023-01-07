extends Node2D
@tool

func _draw() -> void:
	var mi: MeshInstance3D = $MeshInstance

	var sphere_mesh: SphereMesh = mi.mesh

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, sphere_mesh.get_mesh_arrays())

	var mdt := MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)

	var texture: Texture = sphere_mesh.material.albedo_texture
	var t := Transform2D.IDENTITY.scaled(texture.get_size() * 0.5)
	draw_set_transform_matrix(t)

	var edges_uvs := PackedVector2Array()
	for fi in mdt.get_face_count():
		var v0_index: int = mdt.get_face_vertex(fi, 0)
		var v1_index: int = mdt.get_face_vertex(fi, 1)
		var v2_index: int = mdt.get_face_vertex(fi, 2)

		var uv0 = mdt.get_vertex_uv(v0_index)
		var uv1 = mdt.get_vertex_uv(v1_index)
		var uv2 = mdt.get_vertex_uv(v2_index)

		var v0: Vector3 = mdt.get_vertex(v0_index)
		var v1: Vector3 = mdt.get_vertex(v1_index)
		var v2: Vector3 = mdt.get_vertex(v2_index)

		# These won't be visible.
		if v0.is_equal_approx(v1) or v0.is_equal_approx(v2) or v1.is_equal_approx(v2):
			continue

		edges_uvs.append_array(PackedVector2Array([uv0, uv1, uv1, uv2, uv2, uv0]))

		var uvs := PackedVector2Array([uv0, uv1, uv2])
		draw_polygon(uvs, PackedColorArray(), uvs, texture)

	draw_multiline(edges_uvs, Color.WHITE)
