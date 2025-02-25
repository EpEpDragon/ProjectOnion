extends CompositorEffect
class_name PostProcessDither

@export_range(0.5,4,0.1) var threshold_map_scale : float = 1.0
var mask_viewport : SubViewport

var n : int = 3
var _threshold_map : PackedFloat32Array
var _map_dimention : int

var _rd: RenderingDevice
var _shader : RID
var _pipeline : RID
var _mutex := Mutex.new()
var _mask_texture : RID

func _init() -> void:
	_map_dimention = 1 << n
	_generate_threshold_map()
	print(_threshold_map)
	await mask_viewport
	
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	_rd = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_initialize_compute)


func _generate_threshold_map():
	var num_elements := _map_dimention * _map_dimention
	var half_normalized_max_value :=  0.5*(float(num_elements - 1) / num_elements)
	_threshold_map.resize(num_elements)
	
	for y in _map_dimention:
		for x in _map_dimention:
			var current_index = x + _map_dimention*y
			var value : int = 0
			var mask : int = n - 1
			var xc : int = x ^ y
			var yc : int = y
			var bit : int = 0
			while(bit < 2*n):
				value |= ((yc >> mask)&1) << bit
				bit += 1
				value |= ((xc >> mask)&1) << bit
				bit += 1
				mask -= 1
			_threshold_map[current_index] = value / float(_map_dimention*_map_dimention) - half_normalized_max_value
			#_threshold_map[current_index] = _bit_reverse(_bit_interleave(i^j, i), 2*n) \
											#/ float(num_elements) - (0.5 * normalized_max_value)


# System notifications, we want to react on the notification that
# alerts us we are about to be destroyed.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _shader.is_valid():
			# Freeing our _shader will also free any dependents such as the _pipeline!
			_rd.free_rid(_shader)


#region Code in this region runs on the rendering thread.
# Compile our _shader at initialization.
func _initialize_compute() -> void:
	_rd = RenderingServer.get_rendering_device()
	if not _rd:
		return

	# Load shader source.
	var shader_file := FileAccess.open("res://Post/Dither.glsl", FileAccess.READ)
	var shader_source := RDShaderSource.new()
	shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
	shader_source.source_compute = shader_file.get_as_text()
	
	# Insert computed threshold map 
	_mutex.lock()
	shader_source.source_compute = shader_source.source_compute.replace("#MapDim", str(_map_dimention))
	shader_source.source_compute = shader_source.source_compute.replace("#MapSize", str(_map_dimention*_map_dimention))
	shader_source.source_compute = shader_source.source_compute.replace("#Map", str(_threshold_map).lstrip("[").rstrip("]"))
	_mutex.unlock()
	
	# Compile shader
	var shader_spirv := _rd.shader_compile_spirv_from_source(shader_source)
	if shader_spirv.compile_error_compute:
		push_error(shader_spirv.compile_error_compute)
	
	#var shader_file : RDShaderFile = load("res://Post/Post.glsl")
	#var shader_spirv : RDShaderSPIRV = shader_file.get_spirv()

	_shader = _rd.shader_create_from_spirv(shader_spirv)
	if _shader.is_valid():
		_pipeline = _rd.compute_pipeline_create(_shader)


# Called by the rendering thread every frame.
func _render_callback(p_effect_callback_type: EffectCallbackType, p_render_data: RenderData) -> void:
	if _rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and _pipeline.is_valid():
		# Get our render scene buffers object, this gives us access to our render buffers.
		# Note that implementation differs per renderer hence the need for the cast.
		var render_scene_buffers := p_render_data.get_render_scene_buffers()
		if render_scene_buffers:
			# Get our render size, this is the 3D render resolution!
			var size: Vector2i = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			# We can use a compute _shader here.
			@warning_ignore("integer_division")
			var x_groups := (size.x - 1) / 8 + 1
			@warning_ignore("integer_division")
			var y_groups := (size.y - 1) / 8 + 1
			var z_groups := 1

			# Create push constant.
			# Must be aligned to 16 bytes and be in the same order as defined in the _shader.
			var push_constant := PackedFloat32Array([
				size.x,
				size.y,
				1/threshold_map_scale,
				0,
			])

			# Loop through views just in case we're doing stereo rendering. No extra cost if this is mono.
			var view_count: int = render_scene_buffers.get_view_count()
			for view in view_count:
				# Get the RID for our color image, we will be reading from and writing to it.
				var input_image: RID = render_scene_buffers.get_color_layer(view)
				var viewport_texture = mask_viewport.get_texture()
				#print(viewport_texture.get_image().get_pixel(1920/2,1080/2))
				var mask_image = RenderingServer.texture_get_rd_texture(viewport_texture.get_rid())

				# Create a uniform set, this will be cached, the cache will be cleared if our viewports configuration is changed.
				var uniform_in_image := RDUniform.new()
				uniform_in_image.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform_in_image.binding = 0
				uniform_in_image.add_id(input_image)
				var uniform_mask_image := RDUniform.new()
				uniform_mask_image.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform_mask_image.binding = 1
				uniform_mask_image.add_id(mask_image)
				var uniform_set := UniformSetCacheRD.get_cache(_shader, 0, [uniform_in_image, uniform_mask_image])

				# Run our compute _shader.
				var compute_list := _rd.compute_list_begin()
				_rd.compute_list_bind_compute_pipeline(compute_list, _pipeline)
				_rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
				_rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				_rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				_rd.compute_list_end()
#endregion
