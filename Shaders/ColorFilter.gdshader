shader_type canvas_item;

uniform sampler2D palette : source_color;

// 0 = HSV
// 1 = OKLab
uniform int match_mode : hint_range(0,1) = 0;

vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);

	vec4 p = mix(
		vec4(c.bg, K.wz),
		vec4(c.gb, K.xy),
		step(c.b, c.g)
	);

	vec4 q = mix(
		vec4(p.xyw, c.r),
		vec4(c.r, p.yzx),
		step(p.x, c.r)
	);

	float d = q.x - min(q.w, q.y);
	float e = 1e-10;

	return vec3(
		abs(q.z + (q.w - q.y) / (6.0 * d + e)),
		d / (q.x + e),
		q.x
	);
}

vec3 rgb_to_oklab(vec3 c) {

	mat3 m1 = mat3(
		vec3(0.4122214708, 0.5363325363, 0.0514459929),
		vec3(0.2119034982, 0.6806995451, 0.1073969566),
		vec3(0.0883024619, 0.2817188376, 0.6299787005)
		);
	
	mat3 m2 = mat3(
		vec3(0.2104542553, 0.7936177850, -0.0040720468),
		vec3(1.9779984951,-2.4285922050, 0.4505937099),
		vec3(0.0259040371, 0.7827717662,-0.8086757660)
	);

	vec3 lms = m1 * c;

	lms = pow(lms, vec3(1.0 / 3.0));

	return m2 * lms;
}

float hsv_distance(vec3 a, vec3 b) {

	vec3 ah = rgb_to_hsv(a);
	vec3 bh = rgb_to_hsv(b);

	float hue = abs(ah.x - bh.x);
	hue = min(hue, 1.0 - hue);

	return
		hue * hue * 4.0 +
		pow(ah.y - bh.y, 2.0) +
		pow(ah.z - bh.z, 2.0);
}

float oklab_distance(vec3 a, vec3 b) {

	vec3 oa = rgb_to_oklab(a);
	vec3 ob = rgb_to_oklab(b);

	return distance(oa, ob);
}

void fragment() {

	vec4 tex = texture(TEXTURE, UV);

	if (tex.a == 0.0) {
		COLOR = tex;
	} else {

		int palette_size = textureSize(palette, 0).x;

		float best_distance = 1e20;

		vec4 best_color = tex;

		for (int i = 0; i < 4096; i++) {

			if (i >= palette_size)
				break;

			vec4 p = texelFetch(
				palette,
				ivec2(i, 0),
				0
			);

			float d;

			if (match_mode == 0) {
				d = hsv_distance(tex.rgb, p.rgb);
			}
			else {
				d = oklab_distance(tex.rgb, p.rgb);
			}

			if (d < best_distance) {
				best_distance = d;
				best_color = p;
			}
		}

		COLOR = vec4(best_color.rgb, tex.a);
	}
}