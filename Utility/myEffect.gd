extends CompositorEffect
class_name MyEffect

var rd: RenderingDevice
var shader: RID
var pipeline: RID

func _init() -> void:
	rd = RenderingServer.get_rendering_device()

	if rd == null:
		push_error("RenderingDevice é null")
		return

	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT

	var shader_file: RDShaderFile = load("uid://3qv5ljcgjvc8")

	if shader_file == null:
		push_error("Shader file null")
		return

	print(shader_file.base_error)

	var spirv: RDShaderSPIRV = shader_file.get_spirv()

	if spirv == null:
		push_error("SPIRV null")
		return

	shader = rd.shader_create_from_spirv(spirv)
	pipeline = rd.compute_pipeline_create(shader)

func _render_callback(_type: int, render_data: RenderData) -> void:
	var buffers: RenderSceneBuffers = render_data.get_render_scene_buffers()

	if buffers == null:
		return

	var size: Vector2 = buffers.get_internal_size()
	var image: RID = buffers.get_color_layer(0)

	var uniform: RDUniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = 0
	uniform.add_id(image)

	var uniform_set: RID = rd.uniform_set_create([uniform], shader, 0)

	var compute_list: int = rd.compute_list_begin()

	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)

	var groups_x: int = int(ceil(size.x / 8.0))
	var groups_y: int = int(ceil(size.y / 8.0))

	rd.compute_list_dispatch(compute_list, groups_x, groups_y, 1)

	rd.compute_list_add_barrier(compute_list)

	rd.compute_list_end()

	rd.free_rid(uniform_set)
