extends CompositorEffect
class_name CompositorEffectBase

#TODO Finish compositor base class

@export_file("*.glsl") var shader_path

var _rd: RenderingDevice
var _shader : RID
var _pipeline : RID

func _init():
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	_rd = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_initialize_compute)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _shader.is_valid():
			# Freeing our _shader will also free any dependents such as the _pipeline!
			_rd.free_rid(_shader)


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

	# Compile shader
	var shader_spirv := _rd.shader_compile_spirv_from_source(shader_source)
	if shader_spirv.compile_error_compute:
		push_error(shader_spirv.compile_error_compute)
	
	#var shader_file : RDShaderFile = load("res://Post/Post.glsl")
	#var shader_spirv : RDShaderSPIRV = shader_file.get_spirv()

	_shader = _rd.shader_create_from_spirv(shader_spirv)
	if _shader.is_valid():
		_pipeline = _rd.compute_pipeline_create(_shader)
