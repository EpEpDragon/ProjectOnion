#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;
layout(rgba16f, set = 0, binding = 1) uniform image2D coord_mask;

// Our push constant
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	float scale;
	float reserved;
} params;

// Inset threshold map during preprocessor stage
int threshold_map_dimention = #MapDim;
float[#MapSize] threshold_map = float[](#Map);

// The code we want to execute in each invocation
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);

	// Prevent reading/writing out of bounds.
	if (uv.x >= size.x || uv.y >= size.y) {
		return;
	}

	// Read buffers.
	vec4 color = imageLoad(color_image, uv);
	vec2 coord = imageLoad(coord_mask, uv).xy*params.scale;
	coord.x = max(coord.x, uv.x*params.scale);
	coord.y = max(coord.y, uv.y*params.scale);

	// Desaturate.
	float gray = color.r * 0.2125 + color.g * 0.7154 + color.b * 0.0721;

	float threshold = threshold_map[int(mod(coord.x, threshold_map_dimention)) + threshold_map_dimention * int(mod(coord.y, threshold_map_dimention))];
	// color.r = round(color.r + threshold);
	// color.g = round(color.g + threshold);
	// color.b = round(color.b + threshold);
	gray = round(gray + threshold);
	// color.rgb = vec3(mask.xy,0);
	color.rgb = vec3(gray);

	// Write back to our color buffer.
	imageStore(color_image, uv, color);

}