#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);

	ivec2 size = imageSize(color_image);

	if (uv.x >= size.x || uv.y >= size.y) {
		return;
	}

	vec4 color = imageLoad(color_image, uv);

	float gray = (color.r + color.g + color.b) / 3.0;

	imageStore(color_image, uv, vec4(vec3(gray), 1.0));
}